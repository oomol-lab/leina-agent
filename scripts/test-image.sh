#!/bin/sh
# Run image acceptance without credentials, remote inference or persistent data.
set -eu

image="${1:-oomol-hermes-agent:dev}"
docker_cli="${DOCKER:-docker}"

if "$docker_cli" run --rm --network none "$image" true >/dev/null 2>&1; then
    echo "error: image accepted missing runtime environment" >&2
    exit 1
else
    status=$?
    [ "$status" -eq 64 ] || exit "$status"
fi

"$docker_cli" run --rm --network none \
    -e OO_API_KEY=offline-smoke-placeholder \
    -e OO_LLM_BASE_URL=https://example.invalid/v1 \
    -e OO_LLM_MODEL=smoke-model \
    -e OO_LLM_API_MODE=codex_responses \
    "$image" /bin/sh -eu -c '
        test "$(id -u)" = 10000
        test -s "$HERMES_HOME/config.yaml"
        test ! -e "$OO_CONFIG_DIR/auth.toml"
        oo --version
        hermes --help >/dev/null
        /opt/hermes/.venv/bin/python /opt/oomol-hermes-agent/scripts/verify-hermes-runtime.py
        /opt/oomol-hermes-agent/document-venv/bin/python /opt/oomol-hermes-agent/scripts/verify-document-runtime.py
        /opt/oomol-hermes-agent/document-venv/bin/python -c '\''from pathlib import Path; p = Path("/data/.hermes/config.yaml"); p.write_text(p.read_text() + "\n# preserved user customization\n")'\''
        printf "stale account placeholder\n" > "$OO_CONFIG_DIR/auth.toml"
        /opt/oomol-hermes-agent/scripts/entrypoint.sh true
        test ! -e "$OO_CONFIG_DIR/auth.toml"
        /opt/oomol-hermes-agent/document-venv/bin/python -c '\''from pathlib import Path; assert "# preserved user customization" in Path("/data/.hermes/config.yaml").read_text()'\''
    '

"$docker_cli" run --rm --network none \
    -e OO_API_KEY=offline-smoke-placeholder \
    -e OO_LLM_BASE_URL=https://example.invalid/v1 \
    -e OO_LLM_MODEL=smoke-model \
    -e OO_LLM_API_MODE=chat_completions \
    "$image" /opt/hermes/.venv/bin/python -c \
    'from providers import get_provider_profile; p = get_provider_profile("oomol"); assert p and p.api_mode == "chat_completions"'
