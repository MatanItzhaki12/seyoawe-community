"""Static checks on Engine workflow content (no Engine binary)."""

from __future__ import annotations

import pytest

from tests.conftest import REPO_ROOT


@pytest.mark.unit
def test_default_hello_world_workflow_shape():
    path = REPO_ROOT / "Engine" / "workflows" / "default" / "hello-world.yaml"
    text = path.read_text(encoding="utf-8")
    assert "workflow:" in text
    assert "hello-world" in text
    assert "command_module.Command.run" in text


# @pytest.mark.unit
# def test_sample_workflow_contains_expected_fields():
#     path = REPO_ROOT / "Engine" / "workflows" / "samples" / "command_and_slack.yaml"
#     contents = path.read_text(encoding="utf-8")
#     assert "workflow:" in contents
#     assert "trigger:" in contents
#     assert "steps:" in contents
