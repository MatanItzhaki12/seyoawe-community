from pathlib import Path


def test_sample_workflow_contains_expected_fields():
    repo_root = Path(__file__).resolve().parents[1]
    workflow_path = repo_root / "Engine" / "workflows" / "samples" / "command_and_slack.yaml"
    contents = workflow_path.read_text(encoding="utf-8")
    assert "workflow:" in contents
    assert "trigger:" in contents
    assert "steps:" in contents
