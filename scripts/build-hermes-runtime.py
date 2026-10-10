#!/usr/bin/env python3
"""Assemble the CLI/gateway image through Hermes's public build interfaces."""

from __future__ import annotations

import json
import sys
import sysconfig
from pathlib import Path

ROOT = Path("/opt/hermes")
PAYLOAD = ROOT.parent
sys.path.insert(0, str(ROOT))


def main() -> None:
    from pm import stage_manager_runtime
    from pm.store import current_target
    from scripts.bundles.payload import seal_pm_runtime
    from scripts.write_install_stamp import write_stamp

    version, commit = sys.argv[1:]
    python = Path(sys.executable).resolve()
    manager = PAYLOAD / "pm-runtime"
    stage_manager_runtime(python=python, destination=manager, project=ROOT / "pm")
    seal_pm_runtime(PAYLOAD, python)
    stamp = write_stamp(
        ROOT / "install-stamp.json", base_version=version, commit=commit,
        distance=0, source="docker", distribution="docker",
        update_mechanism="external",
    )
    stamp["pmRuntime"] = str(manager)
    (ROOT / "install-stamp.json").write_text(json.dumps(stamp, indent=2) + "\n")

    from pm import build_environment
    from scripts.build.agent import assemble
    from scripts.build.inputs import AgentInputs

    environment = ROOT / ".venv"
    build_environment(
        source=ROOT, out=environment, python=python, extras=["messaging"],
        no_install_project=True, frozen=True, sealed=True, explicit=True,
    )
    site = Path(sysconfig.get_path(
        "purelib", vars={"base": str(environment), "platbase": str(environment)},
    ))
    # Use the upstream offline assembler without Desktop/TUI frontend inputs.
    manifest = assemble(AgentInputs(
        project=ROOT / "pyproject.toml", code=ROOT, repo="hermes", placement="fixed",
        target=current_target(), python=python, site_packages=site,
        environment=environment, tools=PAYLOAD / "tools", pm_runtime=manager,
        bin_dir="libexec", stamp=ROOT / "install-stamp.json",
    ), PAYLOAD)
    # Launchers reset PYTHONPATH. A site binding also works in plugin hosts.
    (site / "oomol-providers.pth").write_text(
        "/opt/oomol-hermes-agent/provider-common\n", encoding="utf-8",
    )
    for name, command in manifest["runtime"]["commands"].items():
        link = environment / "bin" / name
        link.unlink(missing_ok=True)
        link.symlink_to(f"../../../{command}")


if __name__ == "__main__":
    main()
