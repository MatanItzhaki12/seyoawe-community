"""E2E: CLI talks to a live Engine (Docker Compose test stack in CI)."""

from __future__ import annotations

import pytest

from tests.conftest import REPO_ROOT
from tests.helpers import run_sawectl


@pytest.mark.e2e
def test_sawectl_run_hello_world_against_live_engine(live_engine: str):
    wf = REPO_ROOT / "Engine" / "workflows" / "default" / "hello-world.yaml"
    p = run_sawectl(
        "run",
        "--workflow",
        str(wf),
        "--server",
        live_engine,
        capture_output=True,
        text=True,
    )
    assert p.returncode == 0, (p.stdout, p.stderr)
    assert "[SUCCESS]" in p.stdout or "success" in p.stdout.lower()
