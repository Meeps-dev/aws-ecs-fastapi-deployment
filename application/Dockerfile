ARG PYTHON_VERSION=3.12

# ---------------------------------------------------------
# Stage 1: Build Python dependencies in an isolated venv
# ---------------------------------------------------------
FROM python:${PYTHON_VERSION}-slim-bookworm AS builder

ENV PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /build

RUN python -m venv /opt/venv

ENV PATH="/opt/venv/bin:${PATH}"

# Copy dependencies before source code for effective layer caching.
COPY requirements.txt ./requirements.txt

RUN python -m pip install \
    --no-cache-dir \
    --no-compile \
    --requirement requirements.txt


# ---------------------------------------------------------
# Stage 2: Minimal production runtime image
# ---------------------------------------------------------
FROM python:${PYTHON_VERSION}-slim-bookworm AS runtime

ARG APP_UID=10001
ARG APP_GID=10001

ENV PATH="/opt/venv/bin:${PATH}" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app \
    HOME=/home/app

WORKDIR /app

RUN groupadd --gid "${APP_GID}" app \
    && useradd \
        --uid "${APP_UID}" \
        --gid "${APP_GID}" \
        --create-home \
        --no-log-init \
        --shell /usr/sbin/nologin \
        app \
    && chown app:app /app

# Copy only installed runtime dependencies from the builder stage.
COPY --from=builder /opt/venv /opt/venv

# Copy only files required to run the API and Alembic migrations.
COPY --chown=app:app app ./app
COPY --chown=app:app alembic ./alembic
COPY --chown=app:app alembic.ini ./alembic.ini

USER app:app

EXPOSE 8000

HEALTHCHECK --interval=30s \
    --timeout=3s \
    --start-period=10s \
    --retries=3 \
    CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=2).read()"]

CMD ["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
