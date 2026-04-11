"""Invoke the CLI entrypoint the same way CI does (Python, repo root cwd)."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
SAWECTL = REPO_ROOT / "CLI" / "sawectl" / "sawectl.py"


def run_sawectl(
    *args: str,
    check: bool = False,
    capture_output: bool = False,
    text: bool = True,
    env: dict | None = None,
) -> subprocess.CompletedProcess:
    cmd = [sys.executable, str(SAWECTL), *args]
    return subprocess.run(
        cmd,
        cwd=str(REPO_ROOT),
        check=check,
        capture_output=capture_output,
        text=text,
        env=env,
    )
