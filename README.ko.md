<div align="center">

<h1>Leina Agent</h1>

**개발자의 개인 사용을 위한 Leina 오픈 소스 개발자 버전입니다.**

[English](README.md) | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md)

[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE) [![CI](https://github.com/oomol-lab/leina-agent/actions/workflows/ci.yml/badge.svg)](https://github.com/oomol-lab/leina-agent/actions/workflows/ci.yml) [![docker: self-hosted](https://img.shields.io/badge/docker-self--hosted-2496ED?logo=docker&logoColor=white)](compose.yaml) [![linux: amd64 / arm64](https://img.shields.io/badge/linux-amd64%20%2F%20arm64-333333?logo=linux&logoColor=white)](docs/development.md)

</div>

Leina Agent는 공개 버전의 [Hermes Agent](https://github.com/NousResearch/hermes-agent)에 [OO CLI](https://oomol.com/en/cli/), OOMOL Provider, 엄선된 Skills를 통합한 Docker 이미지입니다. 직접 배포하고 확장하여 문서 처리, 웹 조사, 이미지·영상 생성, OOMOL 계정에 연결된 외부 서비스 작업에 사용할 수 있습니다.

Hermes는 Agent 실행 환경을, OOMOL은 호스팅 모델, 미디어 생성, 검색, 외부 서비스 연결을 제공합니다. 이미지에는 CLI와 메시징 Gateway가 포함되며 설정, 세션, 작업 공간 파일을 영구 저장할 수 있습니다.

## 개발자 버전과 SaaS 버전

Dify나 Coze와 같은 실용적인 AI 제품을 찾고 Agent의 사용 방식과 확장을 직접 관리하고 싶다면 Leina를 선택할 수 있습니다. 사용 목적에 맞는 버전을 선택하세요.

| | 오픈 소스 개발자 버전 (이 저장소) | [Leina SaaS](https://leina.ai/) |
| --- | --- | --- |
| 대상 사용자 | 주로 개인적으로 사용하는 개발자 | 조직 또는 바로 사용할 수 있는 제품을 원하는 사용자 |
| Agent Harness | 공개 버전의 Hermes Agent 통합 | Leina가 자체 개발한 조직용 Harness 포함 |
| 조직 기능 | 개인 사용 중심이며 SaaS의 조직 기능은 포함하지 않음 | 조직 사용에 필요한 기능 제공 |

코드, 배포, 실행 환경을 직접 관리하고 개인 요구에 맞게 확장하려는 개발자는 이 저장소를 사용하세요. 조직에서 사용하거나 개발 지식 없이 바로 사용하고 싶다면 Leina SaaS를 선택하세요.

> <img src="https://leina.ai/img/brand/lena-avatar/web/lena-app-icon-180.png" alt="Leina" width="24" height="24"> [Leina SaaS 사용하기](https://leina.ai/). Docker 환경을 직접 배포하고 유지할 필요가 없습니다.

## 포함된 기능

- **OO CLI** — 사전 설치되어 Hermes에서 실행 중 사용할 수 있습니다.
- **OOMOL LLM** — OOMOL 호스팅 언어 모델을 Hermes Model Provider로 사용합니다.
- **이미지 생성** — GPT Image 2와 Nano Banana Provider.
- **영상 생성** — Seedance를 통한 텍스트·이미지 기반 영상 생성.
- **웹 검색** — Jina Reader를 Hermes의 기본 검색 백엔드로 사용합니다.
- **OOMOL 및 OO Skills** — 연결된 서비스 사용, Office·PDF 처리, 공개 소셜 콘텐츠 조사, OO Skill 관리.

## 빠른 시작

<p align="center">
  <a href="https://youtu.be/Vl1IPgq03hg">
    <img src="https://i.ytimg.com/vi/Vl1IPgq03hg/maxresdefault.jpg" alt="Leina Agent 빠른 시작 영상" width="760" />
  </a>
</p>

[YouTube에서 빠른 시작 영상 보기](https://youtu.be/Vl1IPgq03hg).

시작 전 준비 사항:

1. [OOMOL 계정 생성 또는 로그인](https://console.oomol.com/).
2. [개인 API Key 생성](https://console.oomol.com/api-key).
3. Docker와 Docker Compose 설치.

저장소를 복제하고 환경 변수 파일을 만듭니다:

```sh
git clone https://github.com/oomol-lab/leina-agent.git
cd leina-agent
cp .env.example .env
chmod 600 .env
```

`.env`에 OOMOL API Key를 입력합니다:

```dotenv
OO_API_KEY=your-oomol-api-key
```

OOMOL LLM 엔드포인트, 모델, API 모드는 미리 입력되어 있습니다:

```dotenv
OO_LLM_BASE_URL=https://llm.oomol.com/v1
OO_LLM_MODEL=deepseek-v4-flash
OO_LLM_API_MODE=codex_responses
```

권장 모델을 사용하려면 이 값을 유지하세요. 다른 모델을 사용하려면 OOMOL 계정에서 사용할 수 있는 모델로 `OO_LLM_MODEL`을 설정하세요. 위의 `OO_*` 환경 변수 4개는 모두 필수이며, 하나라도 없으면 시작 시 오류가 발생합니다.

포함된 [compose.yaml](compose.yaml)로 게시된 이미지를 가져와 Agent를 시작합니다. 메시징 설정은 선택 사항입니다:

```sh
docker compose pull

# 선택 사항: 대화형 마법사로 메시징 플랫폼 설정
# 설정은 영구 데이터 볼륨에 저장됩니다. 이미 설정했다면 건너뛸 수 있습니다.
# 지원 플랫폼: https://hermes-agent.nousresearch.com/docs/user-guide/messaging/
docker compose run --rm hermes hermes gateway setup

docker compose up -d
docker compose logs -f hermes
```

Compose 서비스는 Hermes 메시징 Gateway를 실행하며 호스트 포트를 공개하지 않습니다. 설정한 메시징 플랫폼에서 Agent와 대화할 수 있습니다. 대화형 CLI를 직접 사용하려면:

```sh
docker compose run --rm hermes hermes
```

## OOMOL 및 OO Skills

이미지에는 다음 OOMOL 및 OO Framework Skills가 추가되어 있습니다:

| 분류 | Skills |
| --- | --- |
| OO 기능 | `oo` |
| Skill 관리 | `oo-find-skills`, `oo-create-skill`, `oo-publish-skill` |
| Office 및 PDF | `office-files`, `pdf-files` |
| 공개 콘텐츠 조사 | `public-social-research` |

이 Skills를 통해 Hermes는 Office·PDF 파일 처리, 공개 소셜 콘텐츠 조사, 연결된 서비스 사용, OO를 통한 Skill 검색 및 관리를 수행할 수 있습니다.

## 설정 및 데이터

이미지와 OOMOL 모델의 추가 설정은 [.env.example](.env.example)을 참고하세요. 게시 이미지 주소는 `ghcr.io/oomol-lab/leina-agent:latest`입니다. 배포 버전을 고정하려면 변경되지 않는 릴리스 태그를 사용하세요. 이미지 게시와 저장소 이름 변경 후 전환은 [릴리스 절차](docs/release.md)를 참고하세요.

Hermes 설정, 세션, OO CLI 상태, 작업 공간 파일은 Compose가 관리하는 `hermes-data` 볼륨에 저장됩니다. `docker compose down`은 볼륨을 유지하고, `docker compose down -v`는 삭제합니다. 시작 시 API Key로 생성한 OO CLI 로그인 상태도 이 볼륨에 저장하여 메시징 세션에서 내장 OO Skills를 사용할 수 있도록 합니다.

`.env`와 데이터 볼륨에는 인증 정보가 포함될 수 있으므로 비공개로 관리하세요. 외부 서비스 인증 정보는 OOMOL Connector에서 관리합니다. OOMOL API Key는 컨테이너에 전달되며 OO CLI 로그인 상태로만 `/data`에 영구 저장됩니다.

기존 컨테이너와 데이터 볼륨을 재사용하도록 Compose 프로젝트 이름은 `oomol-hermes-agent`를 유지합니다. 호환성을 위해 이미지 내부의 `/opt/oomol-hermes-agent` 디렉터리도 원래 이름을 유지합니다.

## 프로젝트 소개

Leina Agent는 Hermes Agent의 Docker 배포판으로 유지됩니다. 이 저장소는 업스트림 버전을 고정하고 OO CLI, 엄선된 Skills, OOMOL Provider Plugins를 포함하여 완성된 이미지를 검증합니다. Hermes는 업스트림 Agent 코어이고 OOMOL은 서비스 제공자입니다.

## 개발

```sh
make test
make build
make compose-up
```

개발용 Compose는 메시징 Gateway만 실행하며 호스트 포트를 공개하지 않습니다. 테스트에는 설정된 메시징 플랫폼을 사용하세요.

자세한 내용은 [개발 가이드](docs/development.md)와 [아키텍처](docs/architecture.md)를 참고하세요.

## 문서 및 기여

아래 상세 문서는 영어로 제공됩니다.

- [개발 가이드](docs/development.md): 로컬 빌드, Docker 테스트, Provider·Skill 개발.
- [아키텍처](docs/architecture.md): 실행 환경 구조, 설정, 데이터 저장.
- [릴리스 절차](docs/release.md): 이미지 버전, 게시, 업그레이드.
- [기여 가이드](CONTRIBUTING.md): 개발 및 Pull Request 지침.
- [문제 신고](https://github.com/oomol-lab/leina-agent/issues) 또는 [보안 정책](SECURITY.md) 확인.

## 라이선스

이 배포판 고유 코드는 MIT License로 제공됩니다. Hermes Agent와 포함된 타사 구성 요소에는 각각의 라이선스가 적용됩니다. [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)를 참고하세요.

## Leina Agent 지원하기

Leina Agent가 유용하다면 [GitHub](https://github.com/oomol-lab/leina-agent)에서 ⭐를 눌러 다른 개발자도 이 프로젝트를 발견할 수 있도록 도와주세요.

## 기여자

Leina Agent에 기여한 모든 분께 감사드립니다. [기여 가이드](CONTRIBUTING.md)를 읽고 참여하세요.

<p align="center">
  <a href="https://github.com/oomol-lab/leina-agent/graphs/contributors">
    <img src="https://contrib.rocks/image?repo=oomol-lab/leina-agent" alt="Leina Agent 기여자" />
  </a>
</p>

## Star 기록

<p align="center">
  <a href="https://www.star-history.com/#oomol-lab/leina-agent&Date">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=oomol-lab/leina-agent&type=Date&theme=dark" />
      <img src="https://api.star-history.com/svg?repos=oomol-lab/leina-agent&type=Date" alt="Leina Agent Star 증가 기록" width="760" />
    </picture>
  </a>
</p>
