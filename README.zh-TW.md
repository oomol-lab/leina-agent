<div align="center">

<h1>Leina Agent</h1>

**Leina 的開源開發版，面向開發者的個人使用。**

[English](README.md) | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md)

[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE) [![CI](https://github.com/oomol-lab/leina-agent/actions/workflows/ci.yml/badge.svg)](https://github.com/oomol-lab/leina-agent/actions/workflows/ci.yml) [![docker: self-hosted](https://img.shields.io/badge/docker-self--hosted-2496ED?logo=docker&logoColor=white)](compose.yaml) [![linux: amd64 / arm64](https://img.shields.io/badge/linux-amd64%20%2F%20arm64-333333?logo=linux&logoColor=white)](docs/development.md)

</div>

Leina Agent 基於公開版本的 [Hermes Agent](https://github.com/NousResearch/hermes-agent)，將 [OO CLI](https://oomol.com/zh-cn/cli/)、OOMOL Provider 和精選 Skills 打包為可自行部署和擴充的 Docker 映像。你可以用它處理文件、研究網頁內容、產生圖片和影片，以及呼叫 OOMOL 帳號中已連接的外部服務。

Hermes 提供 Agent 執行環境，OOMOL 提供託管模型、多媒體生成、搜尋和外部服務連接能力。映像預裝命令列與訊息 Gateway，設定、對話工作階段和工作目錄檔案都會持久化儲存。

## 開發版與 SaaS 版

如果你正在尋找 Dify、Coze 這類實用的 AI 產品，並希望自主掌控 Agent 的使用和擴充，可以選擇 Leina。根據使用情境，Leina 提供開源開發版和 SaaS 版：

| | 開源開發版（本儲存庫） | [Leina SaaS](https://leina.ai/) |
| --- | --- | --- |
| 適用對象 | 主要用於個人使用的開發者 | 組織使用者，或希望開箱即用的非開發者 |
| Agent Harness | 整合公開版本的 Hermes Agent | 包含 Leina 自研的組織版 Harness |
| 組織功能 | 面向個人使用，不包含 SaaS 版的組織功能 | 提供組織使用所需的相關功能 |

開發者可以使用本儲存庫，自行掌控程式碼、部署和執行環境，並按個人需求擴充。組織使用，或沒有相關開發知識、希望開箱即用的使用者，請選擇 Leina SaaS 版。

> <img src="https://leina.ai/img/brand/lena-avatar/web/lena-app-icon-180.png" alt="Leina" width="24" height="24"> [使用 Leina SaaS 版](https://leina.ai/)，無需自行部署和維護 Docker 環境。

## 內建功能

- **OO CLI** — 已安裝在映像中，Hermes 可以在執行時直接使用。
- **OOMOL LLM** — 將 OOMOL 託管的語言模型用作 Hermes Model Provider。
- **圖片生成** — 預先設定 GPT Image 2 和 Nano Banana。
- **影片生成** — 預先設定 Seedance，支援文字生成影片和圖片生成影片。
- **網頁搜尋** — 使用 Jina Reader 作為 Hermes 預設搜尋後端。
- **OOMOL 與 OO Skills** — 呼叫已連接的外部服務、處理 Office 和 PDF、研究公開內容，以及管理 OO Skills。

## 快速開始

<p align="center">
  <a href="https://youtu.be/Vl1IPgq03hg">
    <img src="https://i.ytimg.com/vi/Vl1IPgq03hg/maxresdefault.jpg" alt="Leina Agent 快速入門影片" width="760" />
  </a>
</p>

[在 YouTube 觀看快速入門影片](https://youtu.be/Vl1IPgq03hg)。

開始前：

1. 前往 [OOMOL Console](https://console.oomol.com/) 註冊或登入帳號。
2. [建立個人 API Key](https://console.oomol.com/api-key)。
3. 安裝 Docker 和 Docker Compose。

複製儲存庫並建立環境變數檔案：

```sh
git clone https://github.com/oomol-lab/leina-agent.git
cd leina-agent
cp .env.example .env
chmod 600 .env
```

在 `.env` 中填入 OOMOL API Key：

```dotenv
OO_API_KEY=your-oomol-api-key
```

OOMOL LLM 的位址、模型和 API 模式已經預填：

```dotenv
OO_LLM_BASE_URL=https://llm.oomol.com/v1
OO_LLM_MODEL=deepseek-v4-flash
OO_LLM_API_MODE=codex_responses
```

保留這些值即可使用推薦模型，也可以把 `OO_LLM_MODEL` 改為你的 OOMOL 帳號可用的其他模型。上述四個 `OO_*` 環境變數都是必填項，缺少任意一項都會導致啟動報錯。

使用專案提供的 [compose.yaml](compose.yaml) 拉取發佈映像並啟動 Agent。訊息平台設定為選用步驟：

```sh
docker compose pull

# 選用：透過互動式精靈設定訊息平台
# 設定結果會儲存在持久化資料磁碟區中。如果已設定訊息平台，可以跳過這條命令。
# 支援的平台及其設定要求: https://hermes-agent.nousresearch.com/docs/user-guide/messaging/
docker compose run --rm hermes hermes gateway setup

docker compose up -d
docker compose logs -f hermes
```

Compose 服務執行 Hermes 訊息 Gateway，不向主機開放連接埠。設定訊息平台後，即可在對應平台與 Agent 對話。也可以直接使用互動式命令列：

```sh
docker compose run --rm hermes hermes
```

## OOMOL 與 OO Skills

映像額外加入以下 OOMOL 和 OO Framework Skills：

| 分類 | Skills |
| --- | --- |
| OO 託管功能 | `oo` |
| Skill 管理 | `oo-find-skills`, `oo-create-skill`, `oo-publish-skill` |
| Office 和 PDF | `office-files`, `pdf-files` |
| 公開內容研究 | `public-social-research` |

透過這些 Skills，Hermes 可以處理 Office 和 PDF 檔案、研究公開社群平台內容、呼叫已連接的外部服務，以及透過 OO 尋找和管理其他 Skills。

## 設定與資料

更多設定請見 [.env.example](.env.example)，包括映像和 OOMOL 模型設定。發佈映像位址為 `ghcr.io/oomol-lab/leina-agent:latest`；需要固定部署版本時，請使用不可變的發佈標籤。映像發佈和儲存庫更名後的過渡說明請見 [發佈流程](docs/release.md)。

Hermes 設定、對話工作階段、OO CLI 狀態和工作目錄檔案都儲存在 Docker Compose 管理的 `hermes-data` 資料磁碟區中。`docker compose down` 會保留資料，`docker compose down -v` 會刪除資料磁碟區。啟動時還會把 API Key 儲存成 OO CLI 登入狀態，讓訊息工作階段中的內建 OO Skills 可以正常使用。

請妥善保管 `.env` 和資料磁碟區，兩者都可能包含憑證。外部服務的憑證由 OOMOL Connector 管理；OOMOL API Key 會傳入容器，並僅作為 OO CLI 登入狀態持久化儲存在 `/data` 中。

為讓既有部署繼續使用原來的容器和資料磁碟區，Compose 專案名稱保留為 `oomol-hermes-agent`。映像內部的 `/opt/oomol-hermes-agent` 目錄也保留原名，以相容既有指令碼和使用者 Skills。

## 關於本專案

Leina Agent 以 Hermes Agent 的 Docker 發行版形式維護。本儲存庫固定上游版本，組裝 OO CLI、精選 Skills 和 OOMOL Provider Plugins，並驗證產生的映像。Hermes 繼續作為上游 Agent 核心，OOMOL 繼續作為服務提供方。

## 開發

```sh
make test
make build
make compose-up
```

開發用 Compose 只執行訊息 Gateway，不對主機開放連接埠。測試時請使用已設定的訊息平台。

詳細說明請見 [開發指南](docs/development.md) 和 [架構說明](docs/architecture.md)。

## 文件與貢獻

以下詳細文件目前以英文提供。

- [開發指南](docs/development.md)：本機建置、Docker 測試和 Provider / Skill 開發。
- [架構說明](docs/architecture.md)：執行環境結構、設定和資料儲存。
- [發佈流程](docs/release.md)：映像版本、發佈和升級。
- [貢獻指南](CONTRIBUTING.md)：參與開發和提交 Pull Request。
- [問題回報](https://github.com/oomol-lab/leina-agent/issues)與[安全政策](SECURITY.md)。

## 授權條款

本專案特有的發行版程式碼採用 MIT License。Hermes Agent 和第三方元件保留各自的授權條款，詳見 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。

## 支持 Leina Agent

如果 Leina Agent 對你有幫助，歡迎在 [GitHub](https://github.com/oomol-lab/leina-agent) 點一個 ⭐，幫助更多開發者發現它。

## 貢獻者

感謝每一位參與建設 Leina Agent 的貢獻者。歡迎閱讀 [貢獻指南](CONTRIBUTING.md)，加入我們。

<p align="center">
  <a href="https://github.com/oomol-lab/leina-agent/graphs/contributors">
    <img src="https://contrib.rocks/image?repo=oomol-lab/leina-agent" alt="Leina Agent 貢獻者" />
  </a>
</p>

## Star 歷史

<p align="center">
  <a href="https://www.star-history.com/#oomol-lab/leina-agent&Date">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=oomol-lab/leina-agent&type=Date&theme=dark" />
      <img src="https://api.star-history.com/svg?repos=oomol-lab/leina-agent&type=Date" alt="Leina Agent Star 成長歷史" width="760" />
    </picture>
  </a>
</p>
