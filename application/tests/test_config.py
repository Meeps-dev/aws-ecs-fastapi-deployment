import pytest

from app.config import Settings


@pytest.mark.parametrize("database_url", [None, "", "   "])
def test_settings_require_database_url(monkeypatch, database_url):
    if database_url is None:
        monkeypatch.delenv("DATABASE_URL", raising=False)
    else:
        monkeypatch.setenv("DATABASE_URL", database_url)

    with pytest.raises(
        RuntimeError,
        match="DATABASE_URL environment variable is required",
    ):
        Settings()


def test_settings_read_database_url(monkeypatch):
    database_url = "postgresql://example:p%40ss%25word@localhost:5432/example"
    monkeypatch.setenv("DATABASE_URL", database_url)

    assert Settings().DATABASE_URL == database_url
