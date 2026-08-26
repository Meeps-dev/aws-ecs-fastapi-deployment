#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_ROOT="$(
  cd "$(dirname "${BASH_SOURCE[0]}")/.."
  pwd
)"

RELEASE_REF="${GITHUB_SHA:-HEAD}"
ARTIFACT_PATH=""

usage() {
  echo "Usage: package.sh [--ref <git-ref>] [--output <zip-path>]"
}

while (($# > 0)); do
  case "$1" in
    --ref)
      if (($# < 2)); then
        usage
        exit 1
      fi

      RELEASE_REF="$2"
      shift 2
      ;;

    --output)
      if (($# < 2)); then
        usage
        exit 1
      fi

      ARTIFACT_PATH="$2"
      shift 2
      ;;

    --help|-h)
      usage
      exit 0
      ;;

    *)
      echo "Unknown package option: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ -z "${ARTIFACT_PATH}" ]]; then
  ARTIFACT_PATH="dist/users-posts-api-${RELEASE_REF}.zip"
fi

required_paths=(
  app
  alembic
  alembic.ini
  deploy/users-posts-api.service
  requirements.txt
  scripts/deploy.sh
  scripts/health-check.sh
  scripts/package.sh
  scripts/rollback.sh
)

cd "${PROJECT_ROOT}"

git rev-parse \
  --verify \
  "${RELEASE_REF}^{commit}" \
  >/dev/null

for required_path in "${required_paths[@]}"; do
  if ! git cat-file \
    -e \
    "${RELEASE_REF}:${required_path}"; then

    echo "Package input is missing from ${RELEASE_REF}: ${required_path}"
    exit 1
  fi
done

script_paths=(
  scripts/deploy.sh
  scripts/health-check.sh
  scripts/package.sh
  scripts/rollback.sh
)

for script_path in "${script_paths[@]}"; do
  git show "${RELEASE_REF}:${script_path}" |
    bash -n
done

artifact_directory="$(dirname "${ARTIFACT_PATH}")"
artifact_name="$(basename "${ARTIFACT_PATH}")"

mkdir -p "${artifact_directory}"

git archive \
  --format=zip \
  --output="${ARTIFACT_PATH}" \
  "${RELEASE_REF}" \
  app \
  alembic \
  alembic.ini \
  deploy/users-posts-api.service \
  requirements.txt \
  scripts/deploy.sh \
  scripts/health-check.sh \
  scripts/rollback.sh

(
  cd "${artifact_directory}"

  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "${artifact_name}" \
      > "${artifact_name}.sha256"
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "${artifact_name}" \
      > "${artifact_name}.sha256"
  else
    echo "A SHA-256 checksum command is required."
    exit 1
  fi

  unzip -tq "${artifact_name}"
  unzip -l "${artifact_name}"

  archive_entries="$(unzip -Z1 "${artifact_name}")"

  required_archive_paths=(
    deploy/users-posts-api.service
    scripts/deploy.sh
    scripts/health-check.sh
    scripts/rollback.sh
  )

  for required_archive_path in "${required_archive_paths[@]}"; do
    if ! grep \
      -Fxq \
      "${required_archive_path}" \
      <<< "${archive_entries}"; then

      echo "Packaged artifact is missing: ${required_archive_path}"
      exit 1
    fi
  done

  excluded_archive_paths=(
    scripts/deploy-ec2.sh
    scripts/package.sh
    scripts/run-migrations.sh
    scripts/start-api.sh
  )

  for excluded_archive_path in "${excluded_archive_paths[@]}"; do
    if grep \
      -Fxq \
      "${excluded_archive_path}" \
      <<< "${archive_entries}"; then

      echo "Build-only or legacy file was packaged: ${excluded_archive_path}"
      exit 1
    fi
  done

  if grep \
    -Eq \
    '(^|/)(\.env|\.git|venv|\.venv|__pycache__|\.pytest_cache|reports|tests)(/|$)|\.(db|sqlite|sqlite3)$' \
    <<< "${archive_entries}"; then

    echo "A forbidden file was found in the application artifact."
    exit 1
  fi

  echo "Artifact content checks passed."
)
