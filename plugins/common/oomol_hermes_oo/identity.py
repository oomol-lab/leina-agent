"""Keep OO CLI uploads and connector actions on the same team identity."""

from __future__ import annotations

import os


def team_arguments(*prefixes: str) -> list[str]:
    """Resolve an explicit team, rejecting ambiguous legacy billing selectors.

    With no provider override, oo-cli owns normal OO_TEAM_ID/OO_TEAM_NAME and
    saved-account selection. Legacy personal mode must never silently become
    the account's default team.
    """
    for prefix in prefixes:
        if os.environ.get(f"{prefix}_ORGANIZATION", "").strip():
            raise RuntimeError(
                f"{prefix}_ORGANIZATION is no longer supported; set "
                f"{prefix}_TEAM to an explicit OO team name instead."
            )
        if os.environ.get(f"{prefix}_PERSONAL", "").strip().lower() in {
            "1", "true", "yes", "on",
        }:
            raise RuntimeError(
                f"{prefix}_PERSONAL is no longer supported; select an explicit "
                f"personal team with {prefix}_TEAM before retrying."
            )

    for prefix in prefixes:
        if team := os.environ.get(f"{prefix}_TEAM", "").strip():
            return ["--team", team]
    return []
