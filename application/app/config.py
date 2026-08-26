import os
from pathlib import Path

from dotenv import load_dotenv

PROJECT_ROOT = Path(__file__).resolve().parents[1]

# Explicit environment variables take precedence over the local development file.
load_dotenv(PROJECT_ROOT / ".env", override=False)


class Settings:
    def __init__(self) -> None:
        database_url = os.getenv("DATABASE_URL")

        if not database_url or not database_url.strip():
            raise RuntimeError("DATABASE_URL environment variable is required.")

        self.DATABASE_URL: str = database_url


settings = Settings()
