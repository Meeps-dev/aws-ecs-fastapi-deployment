import os
import subprocess
import sys
from pathlib import Path

from sqlalchemy.engine import make_url

PROJECT_ROOT = Path(__file__).resolve().parents[1]


def test_alembic_accepts_percent_encoded_database_credentials():
    env = os.environ.copy()
    env["DATABASE_URL"] = "postgresql://example:p%40ss%25word@127.0.0.1:5432/example"

    result = subprocess.run(
        [
            str(Path(sys.executable).with_name("alembic")),
            "upgrade",
            "head",
            "--sql",
        ],
        cwd=PROJECT_ROOT,
        env=env,
        capture_output=True,
        text=True,
        check=False,
    )

    assert result.returncode == 0, result.stderr
    assert "DROP TABLE users" not in result.stdout
    assert "DROP TABLE posts" not in result.stdout
    assert make_url(env["DATABASE_URL"]).password == "p@ss%word"
