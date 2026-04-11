"""Shared fixtures and engine readiness for E2E."""

from __future__ import annotations

import os
import socket
import time
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parents[1]


def _split_engine_addr(addr: str) -> tuple[str, int]:
    if ":" not in addr:
        raise ValueError(f"Invalid SEYOAWE_ENGINE (expected host:port): {addr!r}")
    host, _, port_s = addr.rpartition(":")
    return host, int(port_s)


def _tcp_open(host: str, port: int, timeout_s: float = 2.0) -> bool:
    try:
        with socket.create_connection((host, port), timeout=timeout_s):
            return True
    except OSError:
        return False


def wait_for_engine(addr: str, *, total_timeout_s: float) -> bool:
    host, port = _split_engine_addr(addr)
    deadline = time.monotonic() + total_timeout_s
    while time.monotonic() < deadline:
        if _tcp_open(host, port, timeout_s=2.0):
            return True
        time.sleep(2)
    return False


@pytest.fixture(scope="session")
def seyoawe_engine_addr() -> str:
    """host:port for the running Engine (Compose publishes 8080 on the runner host in CI)."""
    return os.environ.get("SEYOAWE_ENGINE", "127.0.0.1:8080")


@pytest.fixture(scope="session")
def live_engine(seyoawe_engine_addr: str) -> str:
    """Skip E2E when no Engine is listening, unless CI where we wait longer."""
    in_ci = os.environ.get("GITHUB_ACTIONS", "").lower() == "true"
    timeout = 120.0 if in_ci else 3.0
    if not wait_for_engine(seyoawe_engine_addr, total_timeout_s=timeout):
        if in_ci:
            pytest.fail(
                f"Engine did not become reachable at {seyoawe_engine_addr} within {timeout:.0f}s"
            )
        pytest.skip(
            f"No Engine at {seyoawe_engine_addr}. "
            "Start the stack: docker compose -f docker-compose.test.yml up -d --build --wait"
        )
    return seyoawe_engine_addr
