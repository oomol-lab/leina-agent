from __future__ import annotations

import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "plugins" / "common"))

from oomol_hermes_oo.identity import team_arguments


@pytest.fixture(autouse=True)
def clean_identity(monkeypatch):
    for prefix in ("OO_GPT_IMAGE_2", "OO_IMAGE"):
        for suffix in ("TEAM", "ORGANIZATION", "PERSONAL"):
            monkeypatch.delenv(f"{prefix}_{suffix}", raising=False)


def test_default_selection_is_owned_by_cli(monkeypatch):
    monkeypatch.setenv("OO_TEAM_NAME", "Account Team")
    assert team_arguments("OO_GPT_IMAGE_2", "OO_IMAGE") == []


def test_provider_team_overrides_shared_team_without_shell_splitting(monkeypatch):
    monkeypatch.setenv("OO_IMAGE_TEAM", "Shared Team")
    monkeypatch.setenv("OO_GPT_IMAGE_2_TEAM", " Product Team ")
    assert team_arguments("OO_GPT_IMAGE_2", "OO_IMAGE") == ["--team", "Product Team"]


def test_shared_team_is_available_to_uploads_and_actions(monkeypatch):
    monkeypatch.setenv("OO_IMAGE_TEAM", "Shared Team")
    assert team_arguments("OO_GPT_IMAGE_2", "OO_IMAGE") == ["--team", "Shared Team"]


@pytest.mark.parametrize("suffix,value", [("ORGANIZATION", "legacy-id"), ("PERSONAL", "true")])
def test_legacy_identity_cannot_silently_change_billing(monkeypatch, suffix, value):
    monkeypatch.setenv(f"OO_IMAGE_{suffix}", value)
    monkeypatch.setenv("OO_GPT_IMAGE_2_TEAM", "New Team")
    with pytest.raises(RuntimeError, match=f"OO_IMAGE_{suffix} is no longer supported") as raised:
        team_arguments("OO_GPT_IMAGE_2", "OO_IMAGE")
    assert "legacy-id" not in str(raised.value)


def test_disabled_legacy_personal_flag_does_not_select_a_team(monkeypatch):
    monkeypatch.setenv("OO_IMAGE_PERSONAL", "false")
    assert team_arguments("OO_GPT_IMAGE_2", "OO_IMAGE") == []
