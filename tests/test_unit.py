from pathlib import Path


def test_sawectl_has_version_constant():
    repo_root = Path(__file__).resolve().parents[1]
    cli_path = repo_root / "CLI" / "sawectl" / "sawectl.py"
    contents = cli_path.read_text(encoding="utf-8")
    assert 'VERSION = "0.0.1"' in contents
