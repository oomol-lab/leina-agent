<div align="center">

<h1>Leina Agent</h1>

**La edición de código abierto de Leina para desarrolladores, pensada para uso personal.**

[English](README.md) | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md)

[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE) [![CI](https://github.com/oomol-lab/leina-agent/actions/workflows/ci.yml/badge.svg)](https://github.com/oomol-lab/leina-agent/actions/workflows/ci.yml) [![docker: self-hosted](https://img.shields.io/badge/docker-self--hosted-2496ED?logo=docker&logoColor=white)](compose.yaml) [![linux: amd64 / arm64](https://img.shields.io/badge/linux-amd64%20%2F%20arm64-333333?logo=linux&logoColor=white)](docs/development.md)

</div>

Leina Agent integra la versión pública de [Hermes Agent](https://github.com/NousResearch/hermes-agent) con [OO CLI](https://oomol.com/en/cli/), proveedores de OOMOL y Skills seleccionadas en una imagen Docker que puedes desplegar y ampliar. Úsala para trabajar con documentos, investigar en la web, generar imágenes y vídeos, y acceder a servicios conectados a tu cuenta de OOMOL.

Hermes proporciona el entorno de ejecución del agente. OOMOL proporciona modelos alojados, generación multimedia, búsqueda y acceso a servicios conectados. La imagen incluye la CLI y el Gateway de mensajería, con almacenamiento persistente para la configuración, las sesiones y los archivos de trabajo.

## Edición para desarrolladores y SaaS

Si buscas un producto de IA práctico como Dify o Coze y quieres controlar cómo usas y amplías tu agente, puedes elegir Leina. Elige la edición que se ajuste a tus necesidades:

| | Edición de código abierto para desarrolladores (este repositorio) | [Leina SaaS](https://leina.ai/) |
| --- | --- | --- |
| Público | Desarrolladores que lo usan principalmente de forma personal | Organizaciones y usuarios que buscan un producto listo para usar |
| Agent Harness | Integra la versión pública de Hermes Agent | Incluye el Harness para organizaciones desarrollado por Leina |
| Funciones para organizaciones | Centrada en el uso personal; no incluye las funciones organizativas de SaaS | Proporciona funciones para uso organizativo |

Usa este repositorio si eres desarrollador y quieres controlar el código, el despliegue y el entorno de ejecución, y ampliar el agente según tus necesidades personales. Elige Leina SaaS para organizaciones o si quieres empezar sin conocimientos de desarrollo.

> <img src="https://leina.ai/img/brand/lena-avatar/web/lena-app-icon-180.png" alt="Leina" width="24" height="24"> [Prueba Leina SaaS](https://leina.ai/) sin desplegar ni mantener un entorno Docker.

## Qué incluye

- **OO CLI** — preinstalada y disponible para Hermes durante la ejecución.
- **OOMOL LLM** — modelos de lenguaje alojados por OOMOL como proveedor de modelos de Hermes.
- **Generación de imágenes** — proveedores GPT Image 2 y Nano Banana.
- **Generación de vídeos** — Seedance para generar vídeos a partir de texto o imágenes.
- **Búsqueda web** — Jina Reader como backend de búsqueda predeterminado de Hermes.
- **OOMOL y OO Skills** — acceso a servicios conectados, procesamiento de Office y PDF, investigación de contenido social público y gestión de OO Skills.

## Inicio rápido

<p align="center">
  <a href="https://youtu.be/Vl1IPgq03hg">
    <img src="https://i.ytimg.com/vi/Vl1IPgq03hg/maxresdefault.jpg" alt="Vídeo de inicio rápido de Leina Agent" width="760" />
  </a>
</p>

[Ver el vídeo de inicio rápido en YouTube](https://youtu.be/Vl1IPgq03hg).

Antes de empezar:

1. [Crea una cuenta de OOMOL o inicia sesión](https://console.oomol.com/).
2. [Crea una API Key personal](https://console.oomol.com/api-key).
3. Instala Docker y Docker Compose.

Clona el repositorio y crea el archivo de variables de entorno:

```sh
git clone https://github.com/oomol-lab/leina-agent.git
cd leina-agent
cp .env.example .env
chmod 600 .env
```

Añade tu API Key de OOMOL a `.env`:

```dotenv
OO_API_KEY=your-oomol-api-key
```

El endpoint, el modelo y el modo de API de OOMOL LLM ya están configurados:

```dotenv
OO_LLM_BASE_URL=https://llm.oomol.com/v1
OO_LLM_MODEL=deepseek-v4-flash
OO_LLM_API_MODE=codex_responses
```

Conserva estos valores para usar el modelo recomendado, o configura `OO_LLM_MODEL` con un modelo disponible para tu cuenta de OOMOL. Las cuatro variables `OO_*` anteriores son obligatorias; si falta alguna, el inicio devuelve un error.

Usa el archivo [compose.yaml](compose.yaml) incluido para descargar la imagen publicada e iniciar el agente. La configuración de mensajería es opcional:

```sh
docker compose pull

# Opcional: configura una plataforma de mensajería con el asistente interactivo
# La configuración se guarda en el volumen persistente. Omite este paso si ya está configurada.
# Plataformas compatibles: https://hermes-agent.nousresearch.com/docs/user-guide/messaging/
docker compose run --rm hermes hermes gateway setup

docker compose up -d
docker compose logs -f hermes
```

El servicio de Compose ejecuta el Gateway de mensajería de Hermes sin exponer un puerto del host. Configura una plataforma de mensajería para hablar con el agente. Para usar directamente la CLI interactiva:

```sh
docker compose run --rm hermes hermes
```

## OOMOL y OO Skills

La imagen añade las siguientes Skills de OOMOL y OO Framework:

| Categoría | Skills |
| --- | --- |
| Capacidades de OO | `oo` |
| Gestión de Skills | `oo-find-skills`, `oo-create-skill`, `oo-publish-skill` |
| Office y PDF | `office-files`, `pdf-files` |
| Investigación pública | `public-social-research` |

Estas Skills permiten a Hermes trabajar con archivos de Office y PDF, investigar contenido social público, usar servicios conectados y buscar o gestionar Skills mediante OO.

## Configuración y datos

Encontrarás más opciones, incluida la configuración de la imagen y del modelo de OOMOL, en [.env.example](.env.example). La imagen se publica en `ghcr.io/oomol-lab/leina-agent:latest`; usa una etiqueta de versión inmutable si necesitas fijar el despliegue. Consulta el [proceso de publicación](docs/release.md) para la publicación de imágenes y la transición tras el cambio de nombre del repositorio.

La configuración de Hermes, las sesiones, el estado de OO CLI y los archivos de trabajo se guardan en el volumen `hermes-data` gestionado por Compose. `docker compose down` conserva el volumen; `docker compose down -v` lo elimina. Al iniciar, la API Key también se guarda allí como estado de inicio de sesión de OO CLI para que las OO Skills incluidas funcionen desde las sesiones de mensajería.

Mantén privados `.env` y el volumen de datos: ambos pueden contener credenciales. OOMOL Connectors gestiona las credenciales de los servicios externos. La API Key de OOMOL se pasa al contenedor y solo se persiste como estado de inicio de sesión de OO CLI en `/data`.

Las instalaciones existentes conservan el nombre de proyecto de Compose `oomol-hermes-agent` para reutilizar los contenedores y el volumen de datos. El directorio interno `/opt/oomol-hermes-agent` también mantiene su nombre por compatibilidad.

## Acerca del proyecto

Leina Agent se mantiene como una distribución Docker de Hermes Agent. Este repositorio fija la versión del entorno de ejecución original, incluye OO CLI, Skills seleccionadas y Plugins de proveedores de OOMOL, y verifica la imagen resultante. Hermes sigue siendo el núcleo del agente y OOMOL el proveedor de servicios.

## Desarrollo

```sh
make test
make build
make compose-up
```

Compose para desarrollo ejecuta únicamente el Gateway de mensajería y no publica puertos del host. Usa una plataforma de mensajería configurada para las pruebas.

Consulta [la guía de desarrollo](docs/development.md) y [la arquitectura](docs/architecture.md) para más información.

## Documentación y contribuciones

La documentación detallada enlazada a continuación está en inglés.

- [Guía de desarrollo](docs/development.md): compilaciones locales, pruebas en Docker y desarrollo de Providers y Skills.
- [Arquitectura](docs/architecture.md): estructura del entorno de ejecución, configuración y almacenamiento de datos.
- [Proceso de publicación](docs/release.md): versiones de imágenes, publicación y actualizaciones.
- [Contribuciones](CONTRIBUTING.md): instrucciones de desarrollo y pull requests.
- [Informa de un problema](https://github.com/oomol-lab/leina-agent/issues) o consulta la [política de seguridad](SECURITY.md).

## Licencia

El código específico de esta distribución se publica bajo la licencia MIT. Hermes Agent y los componentes de terceros incluidos conservan sus propias licencias. Consulta [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## Apoya Leina Agent

Si Leina Agent te resulta útil, dale una ⭐ en [GitHub](https://github.com/oomol-lab/leina-agent) para que otros desarrolladores descubran el proyecto.

## Colaboradores

Gracias a todas las personas que han contribuido a Leina Agent. Consulta [CONTRIBUTING.md](CONTRIBUTING.md) para participar.

<p align="center">
  <a href="https://github.com/oomol-lab/leina-agent/graphs/contributors">
    <img src="https://contrib.rocks/image?repo=oomol-lab/leina-agent" alt="Colaboradores de Leina Agent" />
  </a>
</p>

## Historial de Stars

<p align="center">
  <a href="https://www.star-history.com/#oomol-lab/leina-agent&Date">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=oomol-lab/leina-agent&type=Date&theme=dark" />
      <img src="https://api.star-history.com/svg?repos=oomol-lab/leina-agent&type=Date" alt="Historial de crecimiento de Stars de Leina Agent" width="760" />
    </picture>
  </a>
</p>
