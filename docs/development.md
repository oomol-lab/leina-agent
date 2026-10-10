# Development

## Prerequisites

- Git
- Docker with BuildKit and Docker Compose

Python and `uv` are implementation details inside the build containers. They
do not need to be installed on the development host.

## Repository Tests

```sh
make test
```

These tests validate the version lock, Docker defaults, Skill assembly safety,
OO Skill metadata transformation, and required repository layout. They do not
replace an image build. The equivalent command without Make is:

```sh
docker build --progress=plain \
  --file Dockerfile.test \
  --target repository-tests \
  .
```

## Image Build

```sh
docker build --progress=plain -t oomol-hermes-agent:dev .
```

The build requires internet access to the pinned Hermes repository, OO CLI
artifact host, Debian repositories, and Python package indexes.

Smoke commands:

```sh
docker run --rm -e OO_API_KEY -e OO_LLM_BASE_URL -e OO_LLM_MODEL -e OO_LLM_API_MODE \
  oomol-hermes-agent:dev oo --version
docker run --rm -e OO_API_KEY -e OO_LLM_BASE_URL -e OO_LLM_MODEL -e OO_LLM_API_MODE \
  oomol-hermes-agent:dev hermes --help
docker run --rm -e OO_API_KEY -e OO_LLM_BASE_URL -e OO_LLM_MODEL -e OO_LLM_API_MODE \
  oomol-hermes-agent:dev hermes plugins list --plain
```

Export all four variables before running image commands. `.env.example`
contains the recommended base URL, model, and API mode; never put an API key in
a command literal.

The linux/arm64 and linux/amd64 builds and offline acceptance passed with
Hermes `0.21.6`, OO CLI `1.9.5`, and Python `3.14.7` on 2026-10-10. Validation
used OrbStack on an arm64 host, with amd64 emulation. All five OOMOL providers
were discovered. Native dual-architecture CI remains a release acceptance
check; local validation does not dispatch GitHub workflows or publish images.

For the Hermes 0.21.6 / OO CLI 1.9.5 upgrade, run both the full image build and
the credential-free offline acceptance:

```sh
make build
make integration
```

Acceptance verifies non-root startup, required runtime inputs, first-start
configuration, preservation of an existing configuration, both model API
modes, real discovery of all five OOMOL providers, Skill-description limits,
and representative Office/PDF creation. Containers use `--network none` and
placeholder credentials; no hosted inference or file upload is executed.
CI runs this acceptance on native linux/amd64 and linux/arm64 runners. Passing
the build-time checks alone does not substitute for runtime acceptance.

Hermes uses PM's pinned Python 3.14 and its independent package-manager
runtime. Office/PDF helpers use
`/opt/oomol-hermes-agent/document-venv/bin/python`; do not add their packages to
the Hermes environment. Repository tests intentionally retain a separate
Python 3.11 environment with uv 0.13.0 and pytest 9.1.1.

## Connector Team Migration

OO CLI 1.9.5 selects teams through `--team`. Optional provider overrides are:

| Provider | Team environment variables in priority order |
| --- | --- |
| GPT Image 2 | `OO_GPT_IMAGE_2_TEAM`, `OO_IMAGE_TEAM` |
| Nano Banana | `OO_NANO_BANANA_TEAM`, `OO_IMAGE_TEAM` |
| Seedance | `OO_SEEDANCE_TEAM`, `OO_VIDEO_TEAM` |
| Jina | `OO_JINA_TEAM` |

The same selection applies to reference uploads and connector submit/result
actions. Without an override, the CLI uses its normal team/account selection.
Legacy `*_ORGANIZATION` and enabled `*_PERSONAL` selectors fail with a migration
message instead of silently changing the execution or billing identity. Remove
those selectors and choose the intended explicit team name. A personal
selector cannot safely be translated into the new account default.

## Development Compose

Start the development gateway:

```sh
make compose-up
```

Compose runs the messaging gateway from the locally built image and keeps its
state in the Compose-managed `/data` volume. It does not start the Hermes App
backend or publish a host port; use a configured messaging platform such as
Telegram for development testing.

At startup, the entrypoint uses `OO_API_KEY` to persist an oo-cli login under
`/data/.config/oo`. The operation has a 30-second timeout and is best-effort, so
an authentication or network failure warns without stopping the gateway. The
environment variable remains available to the main Hermes process for its
OOMOL model and provider Plugins, while terminal processes use the saved login.
Authentication is staged before replacing the active account; a failed refresh
removes any prior account instead of allowing terminal work to use stale
credentials.

Runtime tests cover required environment validation, base-URL and API-mode
validation, and invalid `OO_API_KEY` behavior in the connector providers.

To verify the saved authentication without the environment override, run:

```sh
docker compose -f compose.yaml -f compose.dev.yaml exec hermes \
  env -u OO_API_KEY oo auth status --json
```

Never place credentials in build arguments, image layers, command literals, or
committed files. The runtime API key is intentionally persisted as oo-cli state
inside the private `/data` volume.

## Editing Skills

Project-owned Skills live below `skills/`, but only paths in
`config/curated-skills.txt` enter the image. Keep ordinary descriptions concise;
only OO-backed routing that genuinely requires it should opt in to a larger
prompt description.

When adding a dependency, pin it in the relevant requirements file and add a
real build-time verification step.

## Editing Providers

Providers are copied into Hermes's category layout during build. Develop against
the pinned Hermes ABCs, keep network operations bounded, and include sanitized
failure tests. Before adding another provider, extract repeated OO subprocess,
upload, polling, and response-normalization logic into a shared module.

## Useful Checks

```sh
make check
```

`make check` runs repository tests in Docker and then checks the working-tree
diff. Use Linux line endings for all text files.

## Releases

Image releases use immutable date tags, publish multi-platform images to GHCR,
and create a GitHub Release. See [Release Process](release.md) for the workflow,
retry procedure, and optional Feishu notification setup.
