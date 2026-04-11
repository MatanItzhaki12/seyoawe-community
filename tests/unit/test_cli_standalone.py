"""CLI behaviour without a running Engine (standalone)."""

from __future__ import annotations

import importlib.util
import re

import pytest

from tests.conftest import REPO_ROOT


@pytest.mark.unit
def test_sawectl_version_constant_is_semver():
    path = REPO_ROOT / "CLI" / "sawectl" / "sawectl.py"
    spec = importlib.util.spec_from_file_location("sawectl_entry", path)
    assert spec and spec.loader
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    assert hasattr(mod, "VERSION")
    assert re.fullmatch(r"\d+\.\d+\.\d+", mod.VERSION), mod.VERSION


@pytest.mark.unit
def test_sawectl_version_flag_exits_zero():
    from tests.helpers import run_sawectl

    p = run_sawectl("--version", capture_output=True, text=True)
    assert p.returncode == 0
    assert p.stdout.strip()


@pytest.mark.unit
def test_sawectl_help_exits_zero():
    from tests.helpers import run_sawectl

    p = run_sawectl("-h", capture_output=True, text=True)
    assert p.returncode == 0
    assert "sawectl" in p.stdout.lower() or "Usage" in p.stdout


@pytest.mark.unit
def test_deliberate_failure_for_ci_notifications():
    # TEMPORARY: remove this test after verifying Jira + email on-failure steps.
    assert False, "Deliberate failure to test CI notifications"
