<div align="center">

<h1>Leina Agent</h1>

**Leina 的开源开发版，面向开发者的个人使用。**

[English](README.md) | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md)

[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE) [![CI](https://github.com/oomol-lab/leina-agent/actions/workflows/ci.yml/badge.svg)](https://github.com/oomol-lab/leina-agent/actions/workflows/ci.yml) [![docker: self-hosted](https://img.shields.io/badge/docker-self--hosted-2496ED?logo=docker&logoColor=white)](compose.yaml) [![linux: amd64 / arm64](https://img.shields.io/badge/linux-amd64%20%2F%20arm64-333333?logo=linux&logoColor=white)](docs/development.md)

</div>

Leina Agent 基于公开版本的 [Hermes Agent](https://github.com/NousResearch/hermes-agent)，
将 [OO CLI](https://oomol.com/zh-cn/cli/)、OOMOL Provider 和精选 Skills 打包为
可自行部署和扩展的 Docker 镜像。你可以用它处理文档、研究网页内容、生成图片和视频，
以及调用 OOMOL 账号中已连接的外部服务。

Hermes 提供 Agent 运行时，OOMOL 提供托管模型、多媒体生成、搜索和外部服务
连接能力。镜像预装命令行与消息 Gateway，配置、会话和工作目录文件持久化保存。

## 开发版与 SaaS 版

如果你正在寻找 Dify、Coze 这类实用的 AI 产品，并希望自主掌控 Agent 的使用
和扩展，可以选择 Leina。根据使用场景，Leina 提供开源开发版和 SaaS 版：

| | 开源开发版（本仓库） | [Leina SaaS 版](https://leina.ai/) |
| --- | --- | --- |
| 适用人群 | 主要用于个人使用的开发者 | 组织用户，或希望开箱即用的非开发者 |
| Agent Harness | 整合公开版本的 Hermes Agent | 包含 Leina 自研的组织版 Harness |
| 组织功能 | 面向个人使用，不包含 SaaS 版的组织功能 | 提供组织使用所需的相关功能 |

开发者可以使用本仓库，自行掌控代码、部署和运行环境，并按个人需求扩展。
组织使用，或没有相关开发知识、希望开箱即用的用户，请选择 SaaS 版。

> <img src="https://leina.ai/img/brand/lena-avatar/web/lena-app-icon-180.png" alt="Leina" width="24" height="24"> [使用 Leina SaaS 版](https://leina.ai/)，无需自行部署和维护 Docker 环境。

## 内置能力

- **OO CLI**：已经安装在镜像中，Hermes 可以在运行时直接使用。
- **OOMOL LLM**：直接将 OOMOL 托管的语言模型用作 Hermes Model Provider。
- **图片生成**：预配置 GPT Image 2 和 Nano Banana。
- **视频生成**：预配置 Seedance，支持文生视频和图生视频。
- **网页搜索**：使用 Jina Reader 作为 Hermes 默认搜索后端。
- **OOMOL 与 OO Skills**：调用已连接的外部服务、处理 Office 和 PDF、研究公开
  内容，以及管理 OO Skills。

## 快速开始

<p align="center">
  <a href="https://youtu.be/Vl1IPgq03hg">
    <img src="https://i.ytimg.com/vi/Vl1IPgq03hg/maxresdefault.jpg" alt="Leina Agent 快速上手视频" width="760" />
  </a>
</p>

[在 YouTube 观看快速上手视频](https://youtu.be/Vl1IPgq03hg)。

启动前：

1. 前往 [OOMOL Console](https://console.oomol.com/) 注册或登录账号。
2. [创建个人 API Key](https://console.oomol.com/api-key)。
3. 安装 Docker 和 Docker Compose。

克隆仓库并创建环境变量文件：

```sh
git clone https://github.com/oomol-lab/leina-agent.git
cd leina-agent
cp .env.example .env
chmod 600 .env
```

在 `.env` 中填写 OOMOL API Key：

```dotenv
OO_API_KEY=your-oomol-api-key
```

OOMOL LLM 的地址、模型和 API 模式已经预填：

```dotenv
OO_LLM_BASE_URL=https://llm.oomol.com/v1
OO_LLM_MODEL=deepseek-v4-flash
OO_LLM_API_MODE=codex_responses
```

保留这些值即可使用推荐模型，也可以把 `OO_LLM_MODEL` 改为你的 OOMOL 账号
可用的其他模型。上述四个 `OO_*` 环境变量都是必填项，缺少任意一项都会导致
启动报错。

使用项目提供的 [compose.yaml](compose.yaml) 拉取发布镜像并启动 Agent。消息平台
配置为可选步骤：

```sh
docker compose pull

# 可选：通过交互式向导配置消息平台
# 配置结果会保存在持久化数据卷中。如果已经配置过消息平台，可以跳过这条命令。
# 支持的平台及其配置要求：https://hermes-agent.nousresearch.com/docs/user-guide/messaging/
docker compose run --rm hermes hermes gateway setup

docker compose up -d
docker compose logs -f hermes
```

Compose 服务运行 Hermes 消息 Gateway，不向宿主机开放端口。配置消息平台后，
即可在对应平台与 Agent 对话。也可以直接使用交互式命令行：

```sh
docker compose run --rm hermes hermes
```

## OOMOL 与 OO Skills

镜像额外加入以下 OOMOL 和 OO Framework Skills：

| 分类 | Skills |
| --- | --- |
| OO 托管能力 | `oo` |
| Skill 管理 | `oo-find-skills`、`oo-create-skill`、`oo-publish-skill` |
| Office 和 PDF | `office-files`、`pdf-files` |
| 公开内容研究 | `public-social-research` |

通过这些 Skills，Hermes 可以处理 Office 和 PDF 文件、研究公开社交
平台内容、调用已连接的外部服务，以及通过 OO 查找和管理其他 Skills。

## 配置与数据

更多配置见 [.env.example](.env.example)，包括镜像和 OOMOL 模型配置。发布镜像
地址为 `ghcr.io/oomol-lab/leina-agent:latest`；需要固定部署版本时，请使用不可变
的发布标签。镜像发布和仓库更名后的过渡说明见 [发布流程](docs/release.md)。

Hermes 配置、会话、OO CLI 状态和工作目录文件都保存在 Docker Compose 管理的
`hermes-data` Volume 中。`docker compose down` 会保留数据，
`docker compose down -v` 会删除 Volume。启动时还会把运行时 API Key 保存成
oo-cli 登录状态，让消息会话中的内置 OO Skills 可以正常使用。

请妥善保管 `.env` 和数据卷，两者都可能包含凭据。外部服务的凭据由 OOMOL
Connector 管理；OOMOL API Key 会传入容器，并仅作为 OO CLI 登录状态持久化
保存在 `/data` 中。

为让已有部署继续使用原来的容器和数据卷，Compose 项目名保留为
`oomol-hermes-agent`。镜像内部的 `/opt/oomol-hermes-agent` 目录也保留原名，
以兼容已有脚本和用户 Skills。

## 关于本项目

Leina Agent 以 Hermes Agent 的 Docker 发行版形式维护。本仓库固定上游版本，
组装 OO CLI、精选 Skills 和 OOMOL Provider Plugins，并验证生成的镜像。
Hermes 继续作为上游 Agent 核心，OOMOL 继续作为服务提供方。

## 开发

```sh
make test
make build
make compose-up
```

开发 Compose 只运行消息 Gateway，不对宿主机开放端口。测试时请使用已经配置的
消息平台。

详细说明见 [docs/development.md](docs/development.md) 和
[docs/architecture.md](docs/architecture.md)。

## 文档与贡献

- [开发指南](docs/development.md)：本地构建、Docker 测试和 Provider / Skill 开发。
- [架构说明](docs/architecture.md)：运行时结构、配置和数据存储。
- [发布流程](docs/release.md)：镜像版本、发布和升级。
- [贡献指南](CONTRIBUTING.md)：参与开发和提交 Pull Request。
- [问题反馈](https://github.com/oomol-lab/leina-agent/issues)与[安全政策](SECURITY.md)。

## 许可证

本项目特有的发行版代码采用 MIT License。Hermes Agent 和第三方组件保留各自的
许可证，详见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。

## 支持 Leina Agent

如果 Leina Agent 对你有帮助，欢迎在 [GitHub](https://github.com/oomol-lab/leina-agent)
点一个 ⭐，帮助更多开发者发现它。

## 贡献者

感谢每一位参与建设 Leina Agent 的贡献者。欢迎阅读 [贡献指南](CONTRIBUTING.md)，加入我们。

<p align="center">
  <a href="https://github.com/oomol-lab/leina-agent/graphs/contributors">
    <img src="https://contrib.rocks/image?repo=oomol-lab/leina-agent" alt="Leina Agent 贡献者" />
  </a>
</p>

## Star 历史

<p align="center">
  <a href="https://www.star-history.com/#oomol-lab/leina-agent&Date">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=oomol-lab/leina-agent&type=Date&theme=dark" />
      <img src="https://api.star-history.com/svg?repos=oomol-lab/leina-agent&type=Date" alt="Leina Agent Star 增长历史" width="760" />
    </picture>
  </a>
</p>
