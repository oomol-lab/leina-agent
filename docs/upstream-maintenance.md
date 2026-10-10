# Upstream Maintenance

## Contract

`upstream.lock.json` pins an immutable Hermes commit and expected release
version. The Dockerfile duplicates those values as build defaults so normal
`docker build` remains convenient; repository tests require them to match.

Hermes 0.21.6 uses `project.version = "0.0.0"` and a canonical install stamp for
packaged identity. The build verifies that the release tag resolves to the
locked commit, then uses upstream `write_install_stamp` and the offline
assembler. Never compare that placeholder package version to the release pin.
Python and tool versions come from the pinned upstream `pm/lock.json`; use PM
build APIs rather than invoking pip/uv against the Hermes environment.

## Update Procedure

1. Select a Hermes release tag or immutable full commit SHA. Never select a
   moving branch.
2. Review upstream release notes and the diff from the previous pin, focusing on
   Skill parsing, Plugin discovery, provider ABCs, Docker behavior, and config.
3. Update `upstream.lock.json` and the corresponding Docker build defaults.
4. Apply every patch with `git apply --check` against the new source.
5. If a patch fails, review upstream behavior before resolving it. Remove a
   patch when upstream provides the same contract.
6. Run repository tests and a full Docker build.
7. Exercise `oo --version`, `hermes --help`, first-start config seeding, OO
   authentication persistence, every provider registration, and representative
   document generation.
8. Record the compatibility result in `docs/handoff.md` or the release notes.

Keep the upstream update as one dedicated `chore(upstream)` commit. Do not mix
new Skills or provider features into it.

## Patch Policy

The current patch adds an explicit per-Skill prompt-description limit while
leaving Hermes's 60-character default unchanged. It is generic enough to propose
upstream. If accepted upstream, delete the patch and its build application in
the same upstream-update commit.

Never maintain patches by copying complete upstream modules into this project.
