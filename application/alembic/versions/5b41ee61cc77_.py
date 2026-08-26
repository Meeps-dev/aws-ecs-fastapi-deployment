"""preserve the users and posts schema

Revision ID: 5b41ee61cc77
Revises: 5d615fbb68ce
Create Date: 2026-07-28 11:34:08.512200

"""

from typing import Sequence, Union

# revision identifiers, used by Alembic.
revision: str = "5b41ee61cc77"
down_revision: Union[str, Sequence[str], None] = "5d615fbb68ce"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Keep the application tables created by the preceding revision."""


def downgrade() -> None:
    """Keep the application tables when moving to the preceding revision."""
