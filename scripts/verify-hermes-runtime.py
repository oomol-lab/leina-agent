#!/usr/bin/env python3
"""Verify real Hermes identity, Skill parsing and provider discovery offline."""

from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from unittest.mock import patch


def verify_reference_errors(provider, module, prefix: str, workspace: Path) -> None:
    """Reference upload failures must return errors without submitting a task."""
    reference = workspace / "reference.png"
    reference.write_bytes(b"reference-placeholder")
    for inputs in (
        {"image_url": str(reference)},
        {"reference_image_urls": [str(reference)]},
    ):
        for suffix, value in (("ORGANIZATION", "legacy-team"), ("PERSONAL", "true")):
            with (
                patch.dict(os.environ, {f"{prefix}_{suffix}": value}),
                patch.object(module, "require_oo_authentication", return_value=None),
                patch.object(module.subprocess, "run") as run,
                patch.object(module, "_run_oo_connector") as submit,
            ):
                response = provider.generate("reference error smoke", **inputs)
                assert response["success"] is False
                assert response["error_type"] == "RuntimeError"
                assert f"{prefix}_{suffix}" in response["error"]
                run.assert_not_called()
                submit.assert_not_called()

        for failure in (
            subprocess.CompletedProcess([], 1, "private-placeholder", "signed-url-placeholder"),
            subprocess.TimeoutExpired(["oo", "file", "upload"], 300),
        ):
            with (
                patch.object(module, "require_oo_authentication", return_value=None),
                patch.object(module.subprocess, "run") as run,
                patch.object(module, "_run_oo_connector") as submit,
            ):
                if isinstance(failure, subprocess.TimeoutExpired):
                    run.side_effect = failure
                else:
                    run.return_value = failure
                response = provider.generate("reference error smoke", **inputs)
                assert response["success"] is False
                assert response["error_type"] == "RuntimeError"
                assert "private-placeholder" not in response["error"]
                assert "signed-url-placeholder" not in response["error"]
                submit.assert_not_called()


def main() -> None:
    root = Path("/opt/hermes")
    stamp = json.loads((root / "install-stamp.json").read_text())
    assert sys.version_info[:2] == (3, 14)

    with tempfile.TemporaryDirectory(prefix="hermes-runtime-smoke-") as home:
        os.environ["HERMES_HOME"] = home
        os.environ.update(
            OO_API_KEY="build-placeholder", OO_LLM_MODEL="build-model",
            OO_LLM_API_MODE="codex_responses",
            OO_LLM_BASE_URL="https://example.invalid/v1",
        )
        shutil.copyfile(
            "/opt/oomol-hermes-agent/config/config.seed.yaml",
            Path(home) / "config.yaml",
        )
        from agent.skill_utils import (
            extract_skill_description,
            is_skill_description_truncated_for_prompt,
        )
        from hermes_cli.version_info import get_version_info

        identity = get_version_info()
        assert identity.base_version == stamp["baseVersion"]
        assert identity.commit == stamp["commit"]
        assert identity.distribution == "docker"
        description = "x" * 100
        assert len(extract_skill_description({"description": description})) == 60
        for configured, expected in ((1200, 100), (True, 60), (3000, 2000)):
            metadata = {"description": "x" * (2500 if configured == 3000 else 100),
                        "metadata": {"hermes": {"prompt_description_max_chars": configured}}}
            assert len(extract_skill_description(metadata)) == expected
            assert is_skill_description_truncated_for_prompt(metadata) == (expected < len(metadata["description"]))

        from providers import get_provider_profile
        profile = get_provider_profile("oomol")
        assert profile and profile.api_mode == "codex_responses"
        assert not profile.supports_health_check

        from agent.image_gen_registry import get_provider as image_provider
        from agent.video_gen_registry import get_provider as video_provider
        from agent.web_search_registry import get_provider as web_provider
        from hermes_cli.plugins import discover_plugins

        discover_plugins()
        for lookup, name in (
            (image_provider, "oo_gpt_image_2"), (image_provider, "oo_nano_banana"),
            (video_provider, "oo_seedance"), (web_provider, "oo_jina"),
        ):
            provider = lookup(name)
            assert provider is not None, f"provider was not discovered: {name}"
            assert provider.is_available(), f"provider is unavailable: {name}"

        # Exercise the actual CLI adapters without issuing hosted actions.
        import importlib
        for module_name, prefix, lookup in (
            ("plugins.image_gen.oo_gpt_image_2", "OO_GPT_IMAGE_2", image_provider),
            ("plugins.image_gen.oo_nano_banana", "OO_NANO_BANANA", image_provider),
            ("plugins.video_gen.oo_seedance", "OO_SEEDANCE", video_provider),
        ):
            module = importlib.import_module(module_name)
            os.environ[f"{prefix}_TEAM"] = "Smoke Team"
            submitted = subprocess.CompletedProcess([], 0, '{"data":{"sessionId":"smoke"}}', "")
            with patch.object(module.subprocess, "run", return_value=submitted) as run:
                assert module._run_oo_connector("smoke_action", {}, service="fusion-api") == {"sessionId": "smoke"}
                assert run.call_args.args[0][-2:] == ["--team", "Smoke Team"]
                assert run.call_args.kwargs["timeout"] == 900
            uploaded = subprocess.CompletedProcess([], 0, '{"downloadUrl":"https://example.invalid/reference.png"}', "")
            with patch.object(module.subprocess, "run", return_value=uploaded) as run:
                assert module._run_oo_file_upload("/data/reference.png").startswith("https://example.invalid/")
                assert run.call_args.args[0][-2:] == ["--team", "Smoke Team"]
                assert run.call_args.kwargs["timeout"] == 300
            failed = subprocess.CompletedProcess([], 1, "private-prompt-placeholder", "https://example.invalid/signed-placeholder")
            with patch.object(module.subprocess, "run", return_value=failed):
                try:
                    module._run_oo_connector("smoke_action", {}, service="fusion-api")
                except RuntimeError as exc:
                    assert "private-prompt-placeholder" not in str(exc)
                    assert "signed-placeholder" not in str(exc)
                else:
                    raise AssertionError("failed CLI action was accepted")
            registered = lookup(module.PROVIDER_NAME)
            implementation = sys.modules[type(registered).__module__]
            verify_reference_errors(registered, implementation, prefix, Path(home))
            del os.environ[f"{prefix}_TEAM"]
        print("Hermes runtime: identity, Skill limits, five providers and reference errors verified")


if __name__ == "__main__":
    main()
