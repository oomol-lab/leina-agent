<div align="center">

<h1>Leina Agent</h1>

**L’édition open source de Leina pour les développeurs, conçue pour un usage personnel.**

[English](README.md) | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md)

[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE) [![CI](https://github.com/oomol-lab/leina-agent/actions/workflows/ci.yml/badge.svg)](https://github.com/oomol-lab/leina-agent/actions/workflows/ci.yml) [![docker: self-hosted](https://img.shields.io/badge/docker-self--hosted-2496ED?logo=docker&logoColor=white)](compose.yaml) [![linux: amd64 / arm64](https://img.shields.io/badge/linux-amd64%20%2F%20arm64-333333?logo=linux&logoColor=white)](docs/development.md)

</div>

Leina Agent intègre la version publique de [Hermes Agent](https://github.com/NousResearch/hermes-agent), [OO CLI](https://oomol.com/en/cli/), les Providers OOMOL et une sélection de Skills dans une image Docker que vous pouvez déployer et étendre. Elle permet de traiter des documents, d’effectuer des recherches sur le Web, de générer des images et des vidéos et d’utiliser les services connectés à votre compte OOMOL.

Hermes fournit l’environnement d’exécution de l’agent. OOMOL fournit les modèles hébergés, la génération multimédia, la recherche et l’accès aux services connectés. L’image comprend la CLI et le Gateway de messagerie, avec un stockage persistant pour la configuration, les sessions et les fichiers de travail.

## Édition développeur et SaaS

Si vous cherchez un produit d’IA pratique comme Dify ou Coze et souhaitez maîtriser l’utilisation et l’extension de votre agent, vous pouvez choisir Leina. Choisissez l’édition adaptée à vos besoins :

| | Édition open source pour développeurs (ce dépôt) | [Leina SaaS](https://leina.ai/) |
| --- | --- | --- |
| Public | Développeurs utilisant principalement l’agent à titre personnel | Organisations et utilisateurs souhaitant un produit prêt à l’emploi |
| Agent Harness | Intègre la version publique de Hermes Agent | Inclut le Harness pour organisations développé par Leina |
| Fonctions pour organisations | Usage personnel ; ne comprend pas les fonctions organisationnelles de SaaS | Fournit les fonctions nécessaires à un usage en organisation |

Utilisez ce dépôt si vous êtes développeur et souhaitez maîtriser le code, le déploiement et l’environnement d’exécution, et étendre l’agent selon vos besoins personnels. Choisissez Leina SaaS pour un usage en organisation ou pour démarrer sans connaissances en développement.

> <img src="https://leina.ai/img/brand/lena-avatar/web/lena-app-icon-180.png" alt="Leina" width="24" height="24"> [Essayez Leina SaaS](https://leina.ai/) sans déployer ni maintenir vous-même un environnement Docker.

## Fonctionnalités incluses

- **OO CLI** — préinstallée et accessible à Hermes pendant l’exécution.
- **OOMOL LLM** — modèles de langage hébergés par OOMOL comme fournisseur de modèles pour Hermes.
- **Génération d’images** — Providers GPT Image 2 et Nano Banana.
- **Génération de vidéos** — Seedance pour générer des vidéos à partir de textes ou d’images.
- **Recherche Web** — Jina Reader comme moteur de recherche par défaut de Hermes.
- **OOMOL et OO Skills** — accès aux services connectés, traitement de fichiers Office et PDF, recherche de contenus sociaux publics et gestion des OO Skills.

## Démarrage rapide

<p align="center">
  <a href="https://youtu.be/Vl1IPgq03hg">
    <img src="https://i.ytimg.com/vi/Vl1IPgq03hg/maxresdefault.jpg" alt="Vidéo de démarrage rapide de Leina Agent" width="760" />
  </a>
</p>

[Regarder la vidéo de démarrage rapide sur YouTube](https://youtu.be/Vl1IPgq03hg).

Avant de commencer :

1. [Créez un compte OOMOL ou connectez-vous](https://console.oomol.com/).
2. [Créez une API Key personnelle](https://console.oomol.com/api-key).
3. Installez Docker et Docker Compose.

Clonez le dépôt et créez le fichier de variables d’environnement :

```sh
git clone https://github.com/oomol-lab/leina-agent.git
cd leina-agent
cp .env.example .env
chmod 600 .env
```

Ajoutez votre API Key OOMOL dans `.env` :

```dotenv
OO_API_KEY=your-oomol-api-key
```

Le point d’accès, le modèle et le mode d’API OOMOL LLM sont déjà renseignés :

```dotenv
OO_LLM_BASE_URL=https://llm.oomol.com/v1
OO_LLM_MODEL=deepseek-v4-flash
OO_LLM_API_MODE=codex_responses
```

Conservez ces valeurs pour utiliser le modèle recommandé, ou définissez `OO_LLM_MODEL` sur un modèle disponible pour votre compte OOMOL. Les quatre variables `OO_*` ci-dessus sont obligatoires ; le démarrage échoue si l’une d’elles manque.

Utilisez le fichier [compose.yaml](compose.yaml) fourni pour récupérer l’image publiée et démarrer l’agent. La configuration de la messagerie est facultative :

```sh
docker compose pull

# Facultatif : configurez une plateforme de messagerie avec l’assistant interactif
# Les paramètres sont enregistrés dans le volume persistant. Ignorez cette étape si la messagerie est déjà configurée.
# Plateformes prises en charge: https://hermes-agent.nousresearch.com/docs/user-guide/messaging/
docker compose run --rm hermes hermes gateway setup

docker compose up -d
docker compose logs -f hermes
```

Le service Compose exécute le Gateway de messagerie Hermes sans exposer de port sur l’hôte. Configurez une plateforme de messagerie pour dialoguer avec l’agent. Pour utiliser directement la CLI interactive :

```sh
docker compose run --rm hermes hermes
```

## OOMOL et OO Skills

L’image ajoute les Skills OOMOL et OO Framework suivantes :

| Catégorie | Skills |
| --- | --- |
| Fonctions OO | `oo` |
| Gestion des Skills | `oo-find-skills`, `oo-create-skill`, `oo-publish-skill` |
| Office et PDF | `office-files`, `pdf-files` |
| Recherche de contenus publics | `public-social-research` |

Ces Skills permettent à Hermes de traiter les fichiers Office et PDF, d’étudier les contenus sociaux publics, d’utiliser les services connectés et de rechercher ou gérer des Skills via OO.

## Configuration et données

Les paramètres supplémentaires, notamment ceux de l’image et du modèle OOMOL, figurent dans [.env.example](.env.example). L’image est publiée à l’adresse `ghcr.io/oomol-lab/leina-agent:latest` ; utilisez une étiquette de version immuable pour fixer la version d’un déploiement. Consultez le [processus de publication](docs/release.md) pour la publication des images et la transition après le changement de nom du dépôt.

La configuration Hermes, les sessions, l’état de OO CLI et les fichiers de travail sont stockés dans le volume `hermes-data` géré par Compose. `docker compose down` conserve le volume ; `docker compose down -v` le supprime. Au démarrage, l’API Key y est également enregistrée comme état de connexion de OO CLI pour que les OO Skills intégrées fonctionnent depuis les sessions de messagerie.

Gardez `.env` et le volume de données privés : ils peuvent contenir des identifiants. OOMOL Connectors gère les identifiants des services externes. L’API Key OOMOL est transmise au conteneur et n’est conservée dans `/data` que sous forme d’état de connexion de OO CLI.

Les installations existantes conservent le nom de projet Compose `oomol-hermes-agent` afin de réutiliser les conteneurs et le volume de données. Le répertoire interne `/opt/oomol-hermes-agent` garde également son nom pour assurer la compatibilité.

## À propos du projet

Leina Agent est maintenu comme une distribution Docker de Hermes Agent. Ce dépôt fixe la version du moteur amont, intègre OO CLI, une sélection de Skills et les Plugins des Providers OOMOL, puis vérifie l’image obtenue. Hermes reste le cœur de l’agent et OOMOL le fournisseur de services.

## Développement

```sh
make test
make build
make compose-up
```

Compose pour le développement exécute uniquement le Gateway de messagerie et ne publie aucun port sur l’hôte. Utilisez une plateforme de messagerie configurée pour les tests.

Consultez le [guide de développement](docs/development.md) et la [description de l’architecture](docs/architecture.md) pour plus de détails.

## Documentation et contributions

La documentation détaillée ci-dessous est disponible en anglais.

- [Guide de développement](docs/development.md) : builds locaux, tests Docker et développement de Providers et de Skills.
- [Architecture](docs/architecture.md) : environnement d’exécution, configuration et stockage des données.
- [Processus de publication](docs/release.md) : versions des images, publication et mises à jour.
- [Contributions](CONTRIBUTING.md) : règles de développement et pull requests.
- [Signaler un problème](https://github.com/oomol-lab/leina-agent/issues) ou consulter la [politique de sécurité](SECURITY.md).

## Licence

Le code propre à cette distribution est sous licence MIT. Hermes Agent et les composants tiers inclus conservent leurs licences respectives. Consultez [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## Soutenir Leina Agent

Si Leina Agent vous est utile, ajoutez une ⭐ sur [GitHub](https://github.com/oomol-lab/leina-agent) pour aider d’autres développeurs à découvrir le projet.

## Contributeurs

Merci à toutes les personnes qui ont contribué à Leina Agent. Consultez [CONTRIBUTING.md](CONTRIBUTING.md) pour participer.

<p align="center">
  <a href="https://github.com/oomol-lab/leina-agent/graphs/contributors">
    <img src="https://contrib.rocks/image?repo=oomol-lab/leina-agent" alt="Contributeurs de Leina Agent" />
  </a>
</p>

## Historique des Stars

<p align="center">
  <a href="https://www.star-history.com/#oomol-lab/leina-agent&Date">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=oomol-lab/leina-agent&type=Date&theme=dark" />
      <img src="https://api.star-history.com/svg?repos=oomol-lab/leina-agent&type=Date" alt="Évolution des Stars de Leina Agent" width="760" />
    </picture>
  </a>
</p>
