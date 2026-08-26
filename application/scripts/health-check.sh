#!/usr/bin/env bash

set -Eeuo pipefail

HEALTH_CHECK_URL="${1:-${HEALTH_CHECK_URL:-}}"
HEALTH_CHECK_ATTEMPTS="${HEALTH_CHECK_ATTEMPTS:-30}"
HEALTH_CHECK_INTERVAL_SECONDS="${HEALTH_CHECK_INTERVAL_SECONDS:-5}"

if [[ -z "${HEALTH_CHECK_URL}" ]]; then
  echo "Usage: health-check.sh <health-url>"
  exit 1
fi

if [[ ! "${HEALTH_CHECK_ATTEMPTS}" =~ ^[1-9][0-9]*$ ]]; then
  echo "HEALTH_CHECK_ATTEMPTS must be a positive integer."
  exit 1
fi

if [[ ! "${HEALTH_CHECK_INTERVAL_SECONDS}" =~ ^[0-9]+$ ]]; then
  echo "HEALTH_CHECK_INTERVAL_SECONDS must be a non-negative integer."
  exit 1
fi

for ((attempt = 1; attempt <= HEALTH_CHECK_ATTEMPTS; attempt++)); do
  if curl \
    --connect-timeout 3 \
    --max-time 10 \
    -fsS \
    -- \
    "${HEALTH_CHECK_URL}" \
    >/dev/null; then

    echo "Health check passed: ${HEALTH_CHECK_URL}"
    exit 0
  fi

  echo "Health check attempt ${attempt}/${HEALTH_CHECK_ATTEMPTS} failed."

  if ((attempt < HEALTH_CHECK_ATTEMPTS)); then
    sleep "${HEALTH_CHECK_INTERVAL_SECONDS}"
  fi
done

echo "Health check failed: ${HEALTH_CHECK_URL}"
exit 1
