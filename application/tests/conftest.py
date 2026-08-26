from app.database import Base, engine


def pytest_configure(config):
    """Create all database tables before the test session starts."""
    # Import models so that Base.metadata is aware of them
    import app.models.post  # noqa: F401
    import app.models.user  # noqa: F401

    Base.metadata.create_all(bind=engine)
