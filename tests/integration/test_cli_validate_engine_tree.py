"""CLI validation against the real Engine modules/workflows tree on disk."""

from __future__ import annotations

import pytest

from tests.conftest import REPO_ROOT
from tests.helpers import run_sawectl


@pytest.mark.integration
def test_validate_workflow_hello_world_against_engine_modules():
    wf = REPO_ROOT / "Engine" / "workflows" / "default" / "hello-world.yaml"
    mods = REPO_ROOT / "Engine" / "modules"
    p = run_sawectl(
        "validate-workflow",
        "--workflow",
        str(wf),
        "--modules",
        str(mods),
        capture_output=True,
        text=True,
    )
    assert p.returncode == 0, (p.stdout, p.stderr)
    assert "VALIDATION PASSED" in p.stdout


@pytest.mark.integration
def test_validate_modules_engine_tree():
    mods = REPO_ROOT / "Engine" / "modules"
    p = run_sawectl(
        "validate-modules",
        "--modules",
        str(mods),
        capture_output=True,
        text=True,
    )
    assert p.returncode == 0, (p.stdout, p.stderr)
    assert "passed validation" in p.stdout.lower() or "✅" in p.stdout
