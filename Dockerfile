ARG BASE_IMAGE=debian:trixie-slim@sha256:a29215f6a35e51e22adffa17f89e9d2ef06214e64a2bad10d765c46aea49f11f

FROM ${BASE_IMAGE} AS sqlite-build

# Match Hermes's fixed SQLite, including FTS5 for the session store.
ARG SQLITE_VERSION=3530400
ARG SQLITE_SHA256=0e9483900e92cd5de8fd48d16bf9200145a61f7fd5be542a5ac81d8a9516eb9c
RUN apt-get -o Acquire::Retries=3 update \
    && apt-get -o Acquire::Retries=3 install -y --no-install-recommends \
        build-essential ca-certificates curl \
    && curl -fsSL --retry 3 --connect-timeout 15 --max-time 120 \
        "https://sqlite.org/2026/sqlite-autoconf-${SQLITE_VERSION}.tar.gz" \
        -o /tmp/sqlite.tar.gz \
    && echo "${SQLITE_SHA256}  /tmp/sqlite.tar.gz" | sha256sum -c - \
    && tar -xzf /tmp/sqlite.tar.gz -C /tmp \
    && cd "/tmp/sqlite-autoconf-${SQLITE_VERSION}" \
    && CFLAGS="-O2 -DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_COLUMN_METADATA -DSQLITE_ENABLE_RTREE -DSQLITE_THREADSAFE=1" \
        ./configure --prefix=/opt/sqlite-fixed --disable-static \
    && make -j"$(nproc)" && make install

FROM ${BASE_IMAGE}

ARG HERMES_REPOSITORY=https://github.com/NousResearch/hermes-agent.git
ARG HERMES_COMMIT=818c13be1dc4fd28987e1e881a9408224afd4535
ARG HERMES_VERSION=0.21.6
ARG OO_CLI_VERSION=1.9.5
ARG OO_CLI_SHA256_AMD64=8d4f6e004f08e1bceba63171132d1669db17ae959a9dc6a5df5fa9ec9b13ac6c
ARG OO_CLI_SHA256_ARM64=00611657644ab56663f2bdf0e83e2c45986e0a0f76590dbff3492e8c11aaaf31
ARG TARGETARCH
ARG IMAGE_VERSION=dev
ARG IMAGE_REVISION=unknown
ARG IMAGE_SOURCE=https://github.com/oomol-lab/leina-agent
ARG IMAGE_CREATED=unknown

LABEL org.opencontainers.image.title="Leina Agent" \
      org.opencontainers.image.description="Leina Agent: self-hosted AI agent powered by Hermes, with OO CLI, curated Skills, and OOMOL providers" \
      org.opencontainers.image.version="${IMAGE_VERSION}" \
      org.opencontainers.image.revision="${IMAGE_REVISION}" \
      org.opencontainers.image.source="${IMAGE_SOURCE}" \
      org.opencontainers.image.created="${IMAGE_CREATED}" \
      org.opencontainers.image.vendor="OOMOL" \
      org.opencontainers.image.licenses="MIT" \
      com.oomol.hermes.version="${HERMES_VERSION}" \
      com.oomol.oo-cli.version="${OO_CLI_VERSION}"

RUN apt-get -o Acquire::Retries=3 update \
    && apt-get -o Acquire::Retries=3 install -y --no-install-recommends \
    bash ca-certificates curl file git jq less openssh-client \
    fonts-dejavu-core fonts-liberation fonts-noto-cjk fonts-wqy-zenhei \
    libreoffice-calc libreoffice-impress libreoffice-writer pandoc \
    poppler-data poppler-utils qpdf \
    gcc g++ libffi-dev libatomic1 make python3 xz-utils \
    && rm -rf /var/lib/apt/lists/*

COPY --from=sqlite-build /opt/sqlite-fixed/lib/libsqlite3.so.3.53.4 /usr/local/lib/
RUN ln -s libsqlite3.so.3.53.4 /usr/local/lib/libsqlite3.so.0 \
    && echo /usr/local/lib > /etc/ld.so.conf.d/000-sqlite-fixed.conf \
    && ldconfig

WORKDIR /opt/hermes
RUN git init . \
    && git remote add upstream "${HERMES_REPOSITORY}" \
    && for attempt in 1 2 3; do \
        timeout 600s git \
            -c http.version=HTTP/1.1 \
            -c http.lowSpeedLimit=128 \
            -c http.lowSpeedTime=120 \
            fetch --depth 1 upstream "${HERMES_COMMIT}" \
            "refs/tags/v${HERMES_VERSION}:refs/tags/v${HERMES_VERSION}" \
            && break; \
        if [ "${attempt}" -eq 3 ]; then exit 1; fi; \
        sleep "$((attempt * 5))"; \
    done \
    && git checkout --detach "${HERMES_COMMIT}" \
    && test "$(git rev-parse HEAD)" = "${HERMES_COMMIT}" \
    && test "$(git rev-parse "v${HERMES_VERSION}^{commit}")" = "${HERMES_COMMIT}"

COPY patches/0001-skill-description-opt-in.patch /tmp/hermes-patches/
RUN git apply --check /tmp/hermes-patches/0001-skill-description-opt-in.patch \
    && git apply /tmp/hermes-patches/0001-skill-description-opt-in.patch

ENV HERMES_RUNTIME_DIR=/opt/tools
# PM stages the Python/uv versions in the pinned upstream pm/lock.json.
# Debian Python is only the stdlib bootstrap, never the agent interpreter.
RUN python3 -c 'from pm import ensure; [ensure(name, explicit=True) for name in ("uv", "npm", "ffmpeg", "ripgrep")]' \
    && python3 -c 'from pathlib import Path; from pm import installed_package; [Path("/usr/local/bin", command).symlink_to(installed_package(package).binary) for command, package in (("python3", "python"), ("node", "node"), ("npm", "npm"), ("ffmpeg", "ffmpeg"), ("rg", "ripgrep"))]' \
    && ln -s python3 /usr/local/bin/python
# A new shell resolves the staged interpreter instead of a cached Debian path.
RUN python3 -c 'import shutil; from pathlib import Path; from pm import env_for, installed_package; Path("/usr/local/bin/ffprobe").symlink_to(installed_package("ffmpeg").binary.with_name("ffprobe")); Path("/usr/local/bin/npx").symlink_to(shutil.which("npx", path=env_for("npm", base_env={})["PATH"]))' \
    && python3 -c 'import sqlite3, sys; print(sys.version, "SQLite", sqlite3.sqlite_version); assert sys.version_info[:2] == (3, 14); assert sqlite3.sqlite_version_info >= (3, 51, 3); sqlite3.connect(":memory:").execute("CREATE VIRTUAL TABLE smoke USING fts5(content)")' \
    && node --version

COPY scripts/build-hermes-runtime.py /tmp/build-hermes-runtime.py
RUN python3 /tmp/build-hermes-runtime.py "${HERMES_VERSION}" "${HERMES_COMMIT}" \
    && test -x /opt/hermes/.venv/bin/hermes

RUN set -eu; \
    case "${TARGETARCH}" in \
        amd64) oo_platform=x64; oo_sha256="${OO_CLI_SHA256_AMD64}" ;; \
        arm64) oo_platform=arm64; oo_sha256="${OO_CLI_SHA256_ARM64}" ;; \
        *) echo "unsupported OO CLI architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL --retry 3 \
        "https://static.oomol.com/release/apps/oo-cli/${OO_CLI_VERSION}/linux-${oo_platform}/oo" \
        -o /usr/local/bin/oo; \
    echo "${oo_sha256}  /usr/local/bin/oo" | sha256sum -c -; \
    chmod 0755 /usr/local/bin/oo; \
    oo --version

COPY plugins/image_gen/ /opt/hermes/plugins/image_gen/
COPY plugins/model-providers/ /opt/hermes/plugins/model-providers/
COPY plugins/video_gen/ /opt/hermes/plugins/video_gen/
COPY plugins/web/ /opt/hermes/plugins/web/
COPY plugins/common/ /opt/oomol-hermes-agent/provider-common/
COPY skills/ /opt/oomol-hermes-agent/skills/
COPY config/ /opt/oomol-hermes-agent/config/
COPY scripts/ /opt/oomol-hermes-agent/scripts/

RUN cat /opt/oomol-hermes-agent/config/office-python-requirements.txt \
        /opt/oomol-hermes-agent/config/pdf-python-requirements.txt > /tmp/document-requirements.txt \
    && python3 -m pm.build_env --requirements /tmp/document-requirements.txt \
        --out /opt/oomol-hermes-agent/document-venv --python /usr/local/bin/python3 --sealed \
    && python3 /opt/oomol-hermes-agent/scripts/assemble-skills.py \
        --source /opt/hermes/skills \
        --allowlist /opt/oomol-hermes-agent/config/hermes-skills.txt \
        --additional-source /opt/oomol-hermes-agent/skills \
        --additional-allowlist /opt/oomol-hermes-agent/config/curated-skills.txt \
        --output /opt/oomol-hermes-agent/curated-skills \
    && mkdir -p /opt/oomol-hermes-agent/oo-skills \
    && OO_SKILLS_SYNC_DISABLED=true oo skills install \
        --out-dir /opt/oomol-hermes-agent/oo-skills \
        --agent-format hermes \
    && /opt/oomol-hermes-agent/document-venv/bin/python /opt/oomol-hermes-agent/scripts/configure-oo-skills.py \
        --skills-dir /opt/oomol-hermes-agent/oo-skills \
    && test -f /opt/oomol-hermes-agent/oo-skills/oo/SKILL.md \
    && node --check /opt/oomol-hermes-agent/curated-skills/research/public-social-research/scripts/tikhub.mjs \
    && python3 -m compileall -q /opt/hermes/plugins/image_gen/oo_gpt_image_2 \
        /opt/hermes/plugins/image_gen/oo_nano_banana \
        /opt/hermes/plugins/model-providers/oomol \
        /opt/hermes/plugins/video_gen/oo_seedance \
        /opt/hermes/plugins/web/oo_jina \
    && PYTHONPATH=/opt/oomol-hermes-agent/provider-common \
        /opt/hermes/.venv/bin/python -c \
        'import importlib; [importlib.import_module(name) for name in ("plugins.image_gen.oo_gpt_image_2", "plugins.image_gen.oo_nano_banana", "plugins.video_gen.oo_seedance", "plugins.web.oo_jina")]' \
    && OO_API_KEY=build-placeholder \
        OO_LLM_MODEL=build-model \
        OO_LLM_API_MODE=codex_responses \
        OO_LLM_BASE_URL=https://example.invalid/v1 \
        /opt/hermes/.venv/bin/python -c \
        'from providers import get_provider_profile; profile = get_provider_profile("oomol"); assert profile and profile.api_mode == "codex_responses"' \
    && /opt/oomol-hermes-agent/document-venv/bin/python \
        /opt/oomol-hermes-agent/scripts/verify-document-runtime.py \
    && /opt/hermes/.venv/bin/python \
        /opt/oomol-hermes-agent/scripts/verify-hermes-runtime.py

RUN rm -rf /root/.cache /root/.hermes

ARG HERMES_UID=10000
ARG HERMES_GID=10000
RUN groupadd --gid "${HERMES_GID}" hermes \
    && useradd --uid "${HERMES_UID}" --gid hermes \
        --home-dir /data --create-home --shell /bin/bash hermes \
    && mkdir -p /data/.hermes /data/.config/oo /data/workspace \
    && chown -R hermes:hermes /data \
    && chmod 0755 /opt/oomol-hermes-agent/scripts/entrypoint.sh

ENV HOME=/data \
    HERMES_HOME=/data/.hermes \
    HERMES_BUNDLED_SKILLS=/opt/oomol-hermes-agent/curated-skills \
    OO_CONFIG_DIR=/data/.config/oo \
    OO_SKILLS_SYNC_DISABLED=true \
    HERMES_DISABLE_LAZY_INSTALLS=true \
    HERMES_PYTHON=/opt/hermes/.venv/bin/python \
    PYTHONPATH=/opt/oomol-hermes-agent/provider-common \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH=/opt/hermes/.venv/bin:/opt/oomol-hermes-agent/document-venv/bin:/usr/local/bin:/usr/bin:/bin

USER hermes
WORKDIR /data/workspace
VOLUME ["/data"]
ENTRYPOINT ["/opt/oomol-hermes-agent/scripts/entrypoint.sh"]
CMD ["hermes"]
