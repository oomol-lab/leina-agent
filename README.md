<div align="center">

<h1>Leina Agent</h1>

**The open-source developer edition of Leina, built for personal use.**

[English](README.md) | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md)

[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE) [![CI](https://github.com/oomol-lab/leina-agent/actions/workflows/ci.yml/badge.svg)](https://github.com/oomol-lab/leina-agent/actions/workflows/ci.yml) [![docker: self-hosted](https://img.shields.io/badge/docker-self--hosted-2496ED?logo=docker&logoColor=white)](compose.yaml) [![linux: amd64 / arm64](https://img.shields.io/badge/linux-amd64%20%2F%20arm64-333333?logo=linux&logoColor=white)](docs/development.md)

</div>

Leina Agent integrates the public version of
[Hermes Agent](https://github.com/NousResearch/hermes-agent) with
[OO CLI](https://oomol.com/en/cli/), OOMOL providers, and curated Skills in a
Docker image you can deploy and extend yourself. Use it to work with documents,
research the web, generate images and videos, and access services connected to
your OOMOL account.

Hermes provides the agent runtime. OOMOL provides hosted models, media generation,
search, and connected-service access. The image prepares the CLI and messaging
gateway, with persistent configuration, sessions, and workspace files.

## Developer Edition and SaaS

If you are looking for a practical AI product like Dify or Coze and want control
over how you use and extend your agent, consider Leina. Choose the edition that
fits your needs:

| | Open-source developer edition (this repository) | [Leina SaaS](https://leina.ai/) |
| --- | --- | --- |
| Audience | Developers primarily using the agent personally | Organizations and users who want a ready-to-use product |
| Agent harness | Integrates the public version of Hermes Agent | Includes Leina's custom organization harness |
| Organization features | Focused on personal use; excludes the SaaS organization features | Provides features for organizational use |

Use this repository if you are a developer who wants control over the code,
deployment, and runtime, with room to extend the agent for personal needs.
Choose Leina SaaS for organizational use, or if you want a ready-to-use product
without needing development knowledge.

> <img src="https://leina.ai/img/brand/lena-avatar/web/lena-app-icon-180.png" alt="Leina" width="24" height="24"> [Try Leina SaaS](https://leina.ai/) without deploying and maintaining a Docker environment yourself.

## What's Included

- **OO CLI** — preinstalled and available to Hermes at runtime.
- **OOMOL LLM** — use OOMOL-hosted language models as the Hermes model
  provider.
- **Image generation** — GPT Image 2 and Nano Banana providers.
- **Video generation** — Seedance text-to-video and image-to-video provider.
- **Web search** — Jina Reader as the default Hermes search backend.
- **OOMOL and OO Skills** — connected-service access, Office and PDF
  processing, public social research, and OO Skill management.

## Quick Start

<p align="center">
  <a href="https://youtu.be/Vl1IPgq03hg">
    <img src="https://i.ytimg.com/vi/Vl1IPgq03hg/maxresdefault.jpg" alt="Leina Agent quick-start video" width="760" />
  </a>
</p>

[Watch the quick-start video on YouTube](https://youtu.be/Vl1IPgq03hg).

Before starting:

1. [Create or sign in to an OOMOL account](https://console.oomol.com/).
2. [Create a personal API key](https://console.oomol.com/api-key).
3. Install Docker with Docker Compose.

Clone the repository and create the environment file:

```sh
git clone https://github.com/oomol-lab/leina-agent.git
cd leina-agent
cp .env.example .env
chmod 600 .env
```

Add your OOMOL API key to `.env`:

```dotenv
OO_API_KEY=your-oomol-api-key
```

The OOMOL LLM endpoint, model, and API mode are already prefilled:

```dotenv
OO_LLM_BASE_URL=https://llm.oomol.com/v1
OO_LLM_MODEL=deepseek-v4-flash
OO_LLM_API_MODE=codex_responses
```

Keep these values to use the recommended model, or set `OO_LLM_MODEL` to a
model available to your OOMOL account. All four `OO_*` variables above are
required; startup reports an error if any is missing.

Use the included [compose.yaml](compose.yaml) to pull the published image and
start the agent. Messaging setup is optional:

```sh
docker compose pull

# Optional: configure a messaging platform with the interactive wizard
# Settings are saved in the persistent data volume. Skip this command if a
# messaging platform is already configured.
# Supported platforms: https://hermes-agent.nousresearch.com/docs/user-guide/messaging/
docker compose run --rm hermes hermes gateway setup

docker compose up -d
docker compose logs -f hermes
```

The Compose service runs the Hermes messaging gateway without exposing a host
port. Configure a messaging platform to chat with the agent there. To use the
interactive CLI directly, run:

```sh
docker compose run --rm hermes hermes
```

## OOMOL and OO Skills

The image adds the following OOMOL and OO framework Skills:

| Category | Skills |
| --- | --- |
| OO capabilities | `oo` |
| Skill management | `oo-find-skills`, `oo-create-skill`, `oo-publish-skill` |
| Office and PDF | `office-files`, `pdf-files` |
| Public research | `public-social-research` |

These Skills let Hermes work with Office and PDF files,
research public social content, use connected services, and find or manage
Skills through OO.

## Configuration and Data

Additional settings are available in [.env.example](.env.example), including
the image and OOMOL model configuration. The release image address is
`ghcr.io/oomol-lab/leina-agent:latest`; use an immutable release tag when you
need to pin a deployment. See [the release process](docs/release.md) for image
publication and the repository rename transition.

Hermes configuration, sessions, OO CLI state, and workspace files are stored in
the Compose-managed `hermes-data` volume. `docker compose down` preserves the
volume; `docker compose down -v` deletes it. On startup, the runtime API key is
also saved there as oo-cli login state so bundled OO Skills work from messaging
sessions.

Keep `.env` and the data volume private: both can contain credentials. External
service credentials are managed by OOMOL Connectors; the OOMOL API key is passed
to the container and persisted only as OO CLI login state in `/data`.

Existing installations keep the Compose project name `oomol-hermes-agent` so
upgrading reuses the same containers and data volume. The image's internal
`/opt/oomol-hermes-agent` directory also keeps its original name for compatibility.

## About This Project

Leina Agent is maintained as a Docker distribution of Hermes Agent. This
repository pins the upstream runtime, bundles OO CLI, curated Skills, and OOMOL
provider Plugins, and verifies the assembled image. Hermes remains the upstream
agent core; OOMOL remains the service provider.

## Development

```sh
make test
make build
make compose-up
```

Development Compose runs only the messaging gateway and does not publish a host
port. Use a configured messaging platform for testing.

See [docs/development.md](docs/development.md) and
[docs/architecture.md](docs/architecture.md) for details.

## Documentation and Contributing

- [Development guide](docs/development.md): local builds, Docker tests, and Provider / Skill development.
- [Architecture](docs/architecture.md): runtime layout, configuration, and data storage.
- [Release process](docs/release.md): image versions, publishing, and upgrades.
- [Contributing](CONTRIBUTING.md): development guidelines and pull requests.
- [Report an issue](https://github.com/oomol-lab/leina-agent/issues) or read the [security policy](SECURITY.md).

## License

Distribution-specific code is licensed under the MIT License. Hermes Agent and
bundled third-party components retain their own license terms. See
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## Support Leina Agent

If Leina Agent is useful to you, give it a ⭐ on
[GitHub](https://github.com/oomol-lab/leina-agent) to help other developers discover it.

## Contributors

Thanks to everyone who has helped build Leina Agent. See
[CONTRIBUTING.md](CONTRIBUTING.md) to join them.

<p align="center">
  <a href="https://github.com/oomol-lab/leina-agent/graphs/contributors">
    <img src="https://contrib.rocks/image?repo=oomol-lab/leina-agent" alt="Leina Agent contributors" />
  </a>
</p>

## Star History

<p align="center">
  <a href="https://www.star-history.com/#oomol-lab/leina-agent&Date">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=oomol-lab/leina-agent&type=Date&theme=dark" />
      <img src="https://api.star-history.com/svg?repos=oomol-lab/leina-agent&type=Date" alt="Leina Agent star history" width="760" />
    </picture>
  </a>
</p>
