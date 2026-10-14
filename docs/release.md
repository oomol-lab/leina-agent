# Release Process

Leina Agent releases use immutable date tags and publish multi-platform Docker
images to GitHub Container Registry (GHCR). Each release records the pinned
Hermes and OO CLI versions and includes build provenance and an SBOM.

## Release Identity

Release tags have the form `vYYYY.MM.DD-N`, where `N` starts at `1` each UTC
day and increases when multiple releases are made on the same day. They are
annotated tags and contain the pinned Hermes and OO CLI metadata copied from
`upstream.lock.json`.

The lock file remains the canonical version record. A release fails closed if
the annotated tag metadata and the lock file at the tagged commit disagree.

## Automated Release

Run the `Leina Agent image` workflow from the repository's default branch.
The workflow:

1. Creates and pushes the next annotated release tag.
2. Checks out that immutable tag and runs repository tests.
3. Builds `linux/amd64` and `linux/arm64` images with Buildx.
4. Publishes the release tag, full source SHA tag, and `latest` to the GHCR
   package matching `github.repository` (currently
   `ghcr.io/oomol-lab/leina-agent`).
5. Verifies that all published tags resolve to the same registry digest.
6. Publishes a GitHub Release with the commit list, optional AI-generated
   summary, and build metadata.
7. Optionally sends a Feishu Custom Bot webhook notification, including the
   generated summary when available.

The image build emits a maximal provenance attestation and an SBOM.

After the repository rename, new releases publish to
`ghcr.io/oomol-lab/leina-agent`. Renaming a GitHub repository does not move an
existing GHCR package. Publish and verify the first image at the new address
before relying on the updated Compose default. Existing installations can keep
using their previously published image by setting `HERMES_IMAGE` in `.env`.

## Retry An Existing Release

Use the workflow's `reuse_tag` input with an existing `vYYYY.MM.DD-N` tag. The
workflow validates and rebuilds the tagged source instead of creating a new
tag. This is intended only for retrying infrastructure failures; release tags
must never be moved.

## Feishu Notification

Set the repository Actions secret `FEISHU_RELEASE_WEBHOOK` to the custom bot
webhook URL. If the bot has signature verification enabled, also set
`FEISHU_RELEASE_SECRET`. The notification includes the release version, image,
GitHub Release URL, and workflow URL.

If `FEISHU_RELEASE_WEBHOOK` is absent, the notification is skipped.
Notification errors are non-blocking and do not change the release result.

## Optional Release Summary

Set the repository Actions secret `OOMOL_RELEASE_SUMMARY_API_KEY` to generate a
concise Chinese summary with the OpenAI-compatible OOMOL LLM endpoint and the
`deepseek-v4-flash` model. The request contains only the release commit subjects,
changed file paths, and the version-controlled project context in
`scripts/release-summary-context.md`.

The summary is included in both the GitHub Release notes and the Feishu message.
If the secret is absent, this step is skipped. If generation fails, publishing
continues with the normal commit list and without a summary.

## Local Checks

Preview the next tag without changing the repository:

```sh
scripts/prepare-release.sh --dry-run
```

Validate an already-created release without building or pushing an image:

```sh
RELEASE_TAG=v2026.08.17-1 \
RELEASE_COMMIT_SHA="$(git rev-list -n 1 v2026.08.17-1^{commit})" \
IMAGE_REPOSITORY=ghcr.io/oomol-lab/leina-agent \
DRY_RUN=1 \
scripts/release.sh
```

Run `make test` and a complete native image build before the first public
release or after changing the release scripts.
