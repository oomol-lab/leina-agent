<div align="center">

<h1>Leina Agent</h1>

**Leina のオープンソース開発者版。開発者の個人利用を想定しています。**

[English](README.md) | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md)

[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE) [![CI](https://github.com/oomol-lab/leina-agent/actions/workflows/ci.yml/badge.svg)](https://github.com/oomol-lab/leina-agent/actions/workflows/ci.yml) [![docker: self-hosted](https://img.shields.io/badge/docker-self--hosted-2496ED?logo=docker&logoColor=white)](compose.yaml) [![linux: amd64 / arm64](https://img.shields.io/badge/linux-amd64%20%2F%20arm64-333333?logo=linux&logoColor=white)](docs/development.md)

</div>

Leina Agent は公開版の [Hermes Agent](https://github.com/NousResearch/hermes-agent) に [OO CLI](https://oomol.com/en/cli/)、OOMOL の Provider、厳選した Skills を組み合わせた Docker イメージです。自分でデプロイ・拡張し、文書の処理、Web 調査、画像・動画の生成、OOMOL アカウントに接続した外部サービスの操作に使えます。

Hermes が Agent の実行環境を提供し、OOMOL がホスト型モデル、メディア生成、検索、外部サービスとの接続を提供します。イメージには CLI とメッセージング Gateway が含まれ、設定、セッション、ワークスペースのファイルを永続化できます。

## 開発者版と SaaS 版

Dify や Coze のような実用的な AI 製品を探していて、Agent の使い方や拡張を自分で管理したい方には Leina が適しています。用途に合わせて開発者版または SaaS 版を選んでください。

| | オープンソース開発者版（このリポジトリ） | [Leina SaaS](https://leina.ai/) |
| --- | --- | --- |
| 対象ユーザー | 主に個人で利用する開発者 | 組織、またはすぐに使える製品を求めるユーザー |
| Agent Harness | 公開版の Hermes Agent を統合 | Leina 独自の組織向け Harness を含む |
| 組織向け機能 | 個人利用が中心。SaaS 版の組織向け機能は含まない | 組織での利用に必要な機能を提供 |

コード、デプロイ、実行環境を管理し、個人の用途に合わせて拡張したい開発者は、このリポジトリを利用してください。組織での利用や、開発知識なしですぐに使いたい場合は Leina SaaS を選んでください。

> <img src="https://leina.ai/img/brand/lena-avatar/web/lena-app-icon-180.png" alt="Leina" width="24" height="24"> [Leina SaaS を試す](https://leina.ai/)。Docker 環境を自分でデプロイ・保守する必要はありません。

## 含まれる機能

- **OO CLI** — インストール済みで、Hermes から実行時に利用できます。
- **OOMOL LLM** — OOMOL のホスト型言語モデルを Hermes の Model Provider として利用できます。
- **画像生成** — GPT Image 2 と Nano Banana の Provider。
- **動画生成** — Seedance によるテキスト・画像からの動画生成。
- **Web 検索** — Hermes の既定の検索バックエンドとして Jina Reader を使用。
- **OOMOL と OO Skills** — 外部サービスの操作、Office・PDF 処理、公開ソーシャルコンテンツの調査、OO Skill の管理。

## クイックスタート

<p align="center">
  <a href="https://youtu.be/Vl1IPgq03hg">
    <img src="https://i.ytimg.com/vi/Vl1IPgq03hg/maxresdefault.jpg" alt="Leina Agent クイックスタート動画" width="760" />
  </a>
</p>

[YouTube でクイックスタート動画を見る](https://youtu.be/Vl1IPgq03hg)。

開始前に準備するもの：

1. [OOMOL アカウントを作成、またはログイン](https://console.oomol.com/)。
2. [個人用 API Key を作成](https://console.oomol.com/api-key)。
3. Docker と Docker Compose をインストール。

リポジトリをクローンし、環境変数ファイルを作成します：

```sh
git clone https://github.com/oomol-lab/leina-agent.git
cd leina-agent
cp .env.example .env
chmod 600 .env
```

OOMOL API Key を `.env` に設定します：

```dotenv
OO_API_KEY=your-oomol-api-key
```

OOMOL LLM のエンドポイント、モデル、API モードはあらかじめ設定されています：

```dotenv
OO_LLM_BASE_URL=https://llm.oomol.com/v1
OO_LLM_MODEL=deepseek-v4-flash
OO_LLM_API_MODE=codex_responses
```

推奨モデルを使う場合はこれらの値を維持してください。別のモデルを使う場合は、OOMOL アカウントで利用できるモデルを `OO_LLM_MODEL` に設定します。上記の 4 つの `OO_*` 環境変数はすべて必須で、不足すると起動時にエラーになります。

付属の [compose.yaml](compose.yaml) で公開イメージを取得して Agent を起動します。メッセージングの設定は任意です：

```sh
docker compose pull

# 任意：対話式ウィザードでメッセージングプラットフォームを設定
# 設定は永続データボリュームに保存されます。設定済みの場合はスキップできます。
# 対応プラットフォーム: https://hermes-agent.nousresearch.com/docs/user-guide/messaging/
docker compose run --rm hermes hermes gateway setup

docker compose up -d
docker compose logs -f hermes
```

Compose サービスは Hermes のメッセージング Gateway を実行し、ホストのポートは公開しません。設定したプラットフォームから Agent と会話できます。対話式 CLI を直接使う場合：

```sh
docker compose run --rm hermes hermes
```

## OOMOL と OO Skills

イメージには以下の OOMOL および OO Framework Skills が追加されています：

| 分類 | Skills |
| --- | --- |
| OO の機能 | `oo` |
| Skill の管理 | `oo-find-skills`, `oo-create-skill`, `oo-publish-skill` |
| Office と PDF | `office-files`, `pdf-files` |
| 公開コンテンツの調査 | `public-social-research` |

これらの Skills により、Hermes は Office・PDF ファイルの処理、公開ソーシャルコンテンツの調査、接続済みサービスの操作、OO を通じた Skill の検索・管理を行えます。

## 設定とデータ

イメージや OOMOL モデルの追加設定は [.env.example](.env.example) を参照してください。公開イメージのアドレスは `ghcr.io/oomol-lab/leina-agent:latest` です。デプロイのバージョンを固定したい場合は不変のリリースタグを使ってください。公開手順とリポジトリ改名後の移行については [リリース手順](docs/release.md) を参照してください。

Hermes の設定、セッション、OO CLI の状態、ワークスペースのファイルは Compose が管理する `hermes-data` ボリュームに保存されます。`docker compose down` はボリュームを維持し、`docker compose down -v` は削除します。起動時には API Key から OO CLI のログイン状態をこのボリュームに保存し、メッセージセッションから組み込みの OO Skills を使えるようにします。

`.env` とデータボリュームは認証情報を含む場合があるため、非公開で管理してください。外部サービスの認証情報は OOMOL Connector が管理します。OOMOL API Key はコンテナに渡され、OO CLI のログイン状態としてのみ `/data` に永続化されます。

既存のコンテナとデータボリュームを再利用するため、Compose のプロジェクト名は `oomol-hermes-agent` のままです。互換性のため、イメージ内部の `/opt/oomol-hermes-agent` ディレクトリ名も維持しています。

## このプロジェクトについて

Leina Agent は Hermes Agent の Docker ディストリビューションとして保守されています。このリポジトリは上流のバージョンを固定し、OO CLI、厳選した Skills、OOMOL Provider Plugins を組み込み、完成したイメージを検証します。Hermes が上流の Agent コア、OOMOL がサービス提供元です。

## 開発

```sh
make test
make build
make compose-up
```

開発用 Compose はメッセージング Gateway のみを実行し、ホストのポートは公開しません。テストには設定済みのメッセージングプラットフォームを使ってください。

詳細は [開発ガイド](docs/development.md) と [アーキテクチャ](docs/architecture.md) を参照してください。

## ドキュメントとコントリビューション

以下の詳細ドキュメントは英語で提供しています。

- [開発ガイド](docs/development.md)：ローカルビルド、Docker テスト、Provider・Skill 開発。
- [アーキテクチャ](docs/architecture.md)：実行環境、設定、データ保存。
- [リリース手順](docs/release.md)：イメージのバージョン、公開、更新。
- [コントリビューション](CONTRIBUTING.md)：開発と Pull Request のガイド。
- [問題を報告](https://github.com/oomol-lab/leina-agent/issues)、または [セキュリティポリシー](SECURITY.md) を確認してください。

## ライセンス

このディストリビューション固有のコードは MIT License で提供されます。Hermes Agent と同梱の第三者コンポーネントには、それぞれのライセンスが適用されます。[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) を参照してください。

## Leina Agent を応援する

Leina Agent が役立ったら、[GitHub](https://github.com/oomol-lab/leina-agent) で ⭐ を付けて、他の開発者にも見つけてもらえるようにしてください。

## コントリビューター

Leina Agent に貢献してくださった皆さんに感謝します。[コントリビューションガイド](CONTRIBUTING.md) を読んで、ぜひ参加してください。

<p align="center">
  <a href="https://github.com/oomol-lab/leina-agent/graphs/contributors">
    <img src="https://contrib.rocks/image?repo=oomol-lab/leina-agent" alt="Leina Agent のコントリビューター" />
  </a>
</p>

## Star の履歴

<p align="center">
  <a href="https://www.star-history.com/#oomol-lab/leina-agent&Date">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=oomol-lab/leina-agent&type=Date&theme=dark" />
      <img src="https://api.star-history.com/svg?repos=oomol-lab/leina-agent&type=Date" alt="Leina Agent の Star 増加履歴" width="760" />
    </picture>
  </a>
</p>
