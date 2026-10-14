<div align="center">

<h1>Leina Agent</h1>

**Die Open-Source-Entwicklerversion von Leina für den persönlichen Einsatz.**

[English](README.md) | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md)

[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE) [![CI](https://github.com/oomol-lab/leina-agent/actions/workflows/ci.yml/badge.svg)](https://github.com/oomol-lab/leina-agent/actions/workflows/ci.yml) [![docker: self-hosted](https://img.shields.io/badge/docker-self--hosted-2496ED?logo=docker&logoColor=white)](compose.yaml) [![linux: amd64 / arm64](https://img.shields.io/badge/linux-amd64%20%2F%20arm64-333333?logo=linux&logoColor=white)](docs/development.md)

</div>

Leina Agent integriert die öffentliche Version von [Hermes Agent](https://github.com/NousResearch/hermes-agent) mit [OO CLI](https://oomol.com/en/cli/), OOMOL-Providern und ausgewählten Skills in einem Docker-Image, das du selbst bereitstellen und erweitern kannst. Damit kannst du Dokumente bearbeiten, im Web recherchieren, Bilder und Videos generieren und auf Dienste zugreifen, die mit deinem OOMOL-Konto verbunden sind.

Hermes stellt die Agent-Laufzeit bereit. OOMOL bietet gehostete Modelle, Mediengenerierung, Suche und Zugriff auf verbundene Dienste. Das Image enthält CLI und Messaging-Gateway; Konfiguration, Sitzungen und Arbeitsdateien werden dauerhaft gespeichert.

## Entwicklerversion und SaaS

Wenn du ein praktisches KI-Produkt wie Dify oder Coze suchst und selbst bestimmen möchtest, wie du deinen Agent nutzt und erweiterst, kannst du Leina verwenden. Wähle die passende Version für deinen Einsatzzweck:

| | Open-Source-Entwicklerversion (dieses Repository) | [Leina SaaS](https://leina.ai/) |
| --- | --- | --- |
| Zielgruppe | Entwickler, die den Agent hauptsächlich persönlich nutzen | Organisationen und Nutzer, die ein sofort nutzbares Produkt suchen |
| Agent Harness | Integriert die öffentliche Version von Hermes Agent | Enthält Leinas selbst entwickelten Harness für Organisationen |
| Organisationsfunktionen | Für den persönlichen Einsatz; enthält keine Organisationsfunktionen der SaaS-Version | Bietet Funktionen für den Einsatz in Organisationen |

Nutze dieses Repository, wenn du als Entwickler Code, Bereitstellung und Laufzeit selbst kontrollieren und den Agent an deine persönlichen Anforderungen anpassen möchtest. Wähle Leina SaaS für Organisationen oder wenn du ohne Entwicklungskenntnisse sofort loslegen möchtest.

> <img src="https://leina.ai/img/brand/lena-avatar/web/lena-app-icon-180.png" alt="Leina" width="24" height="24"> [Leina SaaS ausprobieren](https://leina.ai/), ohne eine Docker-Umgebung selbst bereitzustellen und zu warten.

## Enthaltene Funktionen

- **OO CLI** — vorinstalliert und zur Laufzeit für Hermes verfügbar.
- **OOMOL LLM** — von OOMOL gehostete Sprachmodelle als Model Provider für Hermes.
- **Bildgenerierung** — Provider für GPT Image 2 und Nano Banana.
- **Videogenerierung** — Seedance für Videos aus Text oder Bildern.
- **Websuche** — Jina Reader als Standard-Suchbackend von Hermes.
- **OOMOL und OO Skills** — Zugriff auf verbundene Dienste, Office- und PDF-Verarbeitung, Recherche öffentlicher Social-Media-Inhalte und Verwaltung von OO Skills.

## Schnellstart

<p align="center">
  <a href="https://youtu.be/Vl1IPgq03hg">
    <img src="https://i.ytimg.com/vi/Vl1IPgq03hg/maxresdefault.jpg" alt="Leina Agent Schnellstart-Video" width="760" />
  </a>
</p>

[Schnellstart-Video auf YouTube ansehen](https://youtu.be/Vl1IPgq03hg).

Vor dem Start:

1. [OOMOL-Konto erstellen oder anmelden](https://console.oomol.com/).
2. [Persönlichen API Key erstellen](https://console.oomol.com/api-key).
3. Docker und Docker Compose installieren.

Klone das Repository und erstelle die Datei für Umgebungsvariablen:

```sh
git clone https://github.com/oomol-lab/leina-agent.git
cd leina-agent
cp .env.example .env
chmod 600 .env
```

Trage deinen OOMOL API Key in `.env` ein:

```dotenv
OO_API_KEY=your-oomol-api-key
```

Endpunkt, Modell und API-Modus für OOMOL LLM sind bereits eingetragen:

```dotenv
OO_LLM_BASE_URL=https://llm.oomol.com/v1
OO_LLM_MODEL=deepseek-v4-flash
OO_LLM_API_MODE=codex_responses
```

Behalte diese Werte für das empfohlene Modell oder setze `OO_LLM_MODEL` auf ein Modell, das deinem OOMOL-Konto zur Verfügung steht. Alle vier oben genannten `OO_*`-Variablen sind erforderlich; fehlt eine davon, schlägt der Start fehl.

Verwende die mitgelieferte [compose.yaml](compose.yaml), um das veröffentlichte Image herunterzuladen und den Agent zu starten. Die Messaging-Konfiguration ist optional:

```sh
docker compose pull

# Optional: Messaging-Plattform mit dem interaktiven Assistenten konfigurieren
# Die Einstellungen werden im dauerhaften Datenvolume gespeichert. Bei vorhandener Konfiguration überspringen.
# Unterstützte Plattformen: https://hermes-agent.nousresearch.com/docs/user-guide/messaging/
docker compose run --rm hermes hermes gateway setup

docker compose up -d
docker compose logs -f hermes
```

Der Compose-Dienst startet das Hermes-Messaging-Gateway, ohne einen Host-Port freizugeben. Konfiguriere eine Messaging-Plattform, um dort mit dem Agent zu sprechen. Für die direkte Nutzung der interaktiven CLI:

```sh
docker compose run --rm hermes hermes
```

## OOMOL und OO Skills

Das Image ergänzt die folgenden OOMOL- und OO-Framework-Skills:

| Kategorie | Skills |
| --- | --- |
| OO-Funktionen | `oo` |
| Skill-Verwaltung | `oo-find-skills`, `oo-create-skill`, `oo-publish-skill` |
| Office und PDF | `office-files`, `pdf-files` |
| Öffentliche Recherche | `public-social-research` |

Mit diesen Skills kann Hermes Office- und PDF-Dateien bearbeiten, öffentliche Social-Media-Inhalte recherchieren, verbundene Dienste nutzen und über OO Skills suchen oder verwalten.

## Konfiguration und Daten

Weitere Einstellungen für Image und OOMOL-Modell findest du in [.env.example](.env.example). Das Release-Image liegt unter `ghcr.io/oomol-lab/leina-agent:latest`; verwende einen unveränderlichen Release-Tag, um eine Version festzulegen. Informationen zur Veröffentlichung und zum Übergang nach der Repository-Umbenennung stehen im [Release-Prozess](docs/release.md).

Hermes-Konfiguration, Sitzungen, OO-CLI-Zustand und Arbeitsdateien werden im Compose-Volume `hermes-data` gespeichert. `docker compose down` erhält das Volume; `docker compose down -v` löscht es. Beim Start wird der API Key dort auch als OO-CLI-Anmeldezustand gespeichert, damit die eingebauten OO Skills aus Messaging-Sitzungen funktionieren.

Halte `.env` und das Datenvolume privat: Beide können Zugangsdaten enthalten. Zugangsdaten externer Dienste werden von OOMOL Connectors verwaltet. Der OOMOL API Key wird an den Container übergeben und nur als OO-CLI-Anmeldezustand unter `/data` dauerhaft gespeichert.

Bestehende Installationen behalten den Compose-Projektnamen `oomol-hermes-agent`, damit Container und Datenvolume weiterverwendet werden. Das interne Verzeichnis `/opt/oomol-hermes-agent` behält aus Kompatibilitätsgründen ebenfalls seinen Namen.

## Über dieses Projekt

Leina Agent wird als Docker-Distribution von Hermes Agent gepflegt. Dieses Repository legt die Upstream-Version fest, bündelt OO CLI, ausgewählte Skills und OOMOL-Provider-Plugins und prüft das fertige Image. Hermes bleibt der Agent-Kern, OOMOL der Dienstanbieter.

## Entwicklung

```sh
make test
make build
make compose-up
```

Die Entwicklungs-Compose-Konfiguration startet nur das Messaging-Gateway und veröffentlicht keinen Host-Port. Nutze eine konfigurierte Messaging-Plattform zum Testen.

Details findest du im [Entwicklungsleitfaden](docs/development.md) und in der [Architekturbeschreibung](docs/architecture.md).

## Dokumentation und Beiträge

Die folgenden ausführlichen Dokumente sind auf Englisch verfügbar.

- [Entwicklungsleitfaden](docs/development.md): lokale Builds, Docker-Tests sowie Provider- und Skill-Entwicklung.
- [Architektur](docs/architecture.md): Laufzeitstruktur, Konfiguration und Datenspeicherung.
- [Release-Prozess](docs/release.md): Image-Versionen, Veröffentlichung und Updates.
- [Beiträge](CONTRIBUTING.md): Richtlinien für Entwicklung und Pull Requests.
- [Problem melden](https://github.com/oomol-lab/leina-agent/issues) oder die [Sicherheitsrichtlinie](SECURITY.md) lesen.

## Lizenz

Der distributionsspezifische Code steht unter der MIT-Lizenz. Hermes Agent und gebündelte Drittanbieterkomponenten behalten ihre jeweiligen Lizenzen. Siehe [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## Leina Agent unterstützen

Wenn Leina Agent dir hilft, vergib auf [GitHub](https://github.com/oomol-lab/leina-agent) einen ⭐, damit andere Entwickler das Projekt entdecken.

## Mitwirkende

Vielen Dank an alle, die an Leina Agent mitarbeiten. Lies [CONTRIBUTING.md](CONTRIBUTING.md), um ebenfalls beizutragen.

<p align="center">
  <a href="https://github.com/oomol-lab/leina-agent/graphs/contributors">
    <img src="https://contrib.rocks/image?repo=oomol-lab/leina-agent" alt="Mitwirkende an Leina Agent" />
  </a>
</p>

## Star-Verlauf

<p align="center">
  <a href="https://www.star-history.com/#oomol-lab/leina-agent&Date">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=oomol-lab/leina-agent&type=Date&theme=dark" />
      <img src="https://api.star-history.com/svg?repos=oomol-lab/leina-agent&type=Date" alt="Star-Wachstum von Leina Agent" width="760" />
    </picture>
  </a>
</p>
