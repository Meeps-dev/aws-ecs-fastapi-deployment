#!/usr/bin/env bash

set -uo pipefail

: "${CURRENT_LINK:?CURRENT_LINK must be configured}"
: "${SERVICE_NAME:?SERVICE_NAME must be configured}"
: "${SERVICE_UNIT_PATH:?SERVICE_UNIT_PATH must be configured}"
: "${SERVICE_UNIT_BACKUP:?SERVICE_UNIT_BACKUP must be configured}"
: "${PLACEHOLDER_SERVICE:?PLACEHOLDER_SERVICE must be configured}"
: "${EXPECTED_PORT:?EXPECTED_PORT must be configured}"
: "${HEALTH_CHECK_SCRIPT:?HEALTH_CHECK_SCRIPT must be configured}"

PREVIOUS_RELEASE="${PREVIOUS_RELEASE:-}"
SWITCHED_RELEASE="${SWITCHED_RELEASE:-false}"
PLACEHOLDER_WAS_ACTIVE="${PLACEHOLDER_WAS_ACTIVE:-false}"
SERVICE_UNIT_CHANGED="${SERVICE_UNIT_CHANGED:-false}"

rollback_failed="false"

echo "Deployment failed. Starting rollback."

if [[ "${SERVICE_UNIT_CHANGED}" == "true" ]]; then
  previous_unit="${PREVIOUS_RELEASE}/deploy/${SERVICE_NAME}"

  if [[ -n "${PREVIOUS_RELEASE}" ]] &&
     [[ -f "${previous_unit}" ]]; then

    echo "Restoring the previous release's systemd unit."

    if ! install \
      -o root \
      -g root \
      -m 0644 \
      "${previous_unit}" \
      "${SERVICE_UNIT_PATH}"; then

      echo "Could not restore ${SERVICE_NAME} from the previous release."
      rollback_failed="true"
    fi

  elif [[ -f "${SERVICE_UNIT_BACKUP}" ]]; then
    echo "Restoring the pre-deployment systemd unit."

    if ! install \
      -o root \
      -g root \
      -m 0644 \
      "${SERVICE_UNIT_BACKUP}" \
      "${SERVICE_UNIT_PATH}"; then

      echo "Could not restore the pre-deployment systemd unit."
      rollback_failed="true"
    fi

  elif [[ -n "${PREVIOUS_RELEASE}" ]]; then
    echo "No previous systemd unit is available to restore."
    rollback_failed="true"
  fi
fi

if [[ "${SWITCHED_RELEASE}" == "true" ]] &&
   [[ -n "${PREVIOUS_RELEASE}" ]] &&
   [[ -d "${PREVIOUS_RELEASE}" ]]; then

  echo "Restoring previous release: ${PREVIOUS_RELEASE}"

  if ! ln -sfn \
    "${PREVIOUS_RELEASE}" \
    "${CURRENT_LINK}"; then

    echo "Could not restore the previous release symlink."
    rollback_failed="true"
  fi

  if ! systemctl daemon-reload; then
    echo "Could not reload systemd during rollback."
    rollback_failed="true"
  fi

  if ! systemctl restart "${SERVICE_NAME}"; then
    echo "Could not restart ${SERVICE_NAME} during rollback."
    rollback_failed="true"
  elif ! HEALTH_CHECK_ATTEMPTS=20 \
    HEALTH_CHECK_INTERVAL_SECONDS=3 \
    bash \
      "${HEALTH_CHECK_SCRIPT}" \
      "http://127.0.0.1:${EXPECTED_PORT}/health"; then

    echo "The restored release did not become healthy."
    rollback_failed="true"
  fi

elif [[ "${SWITCHED_RELEASE}" == "true" ]] &&
     [[ -f "${SERVICE_UNIT_PATH}" ]]; then

  echo "No previous FastAPI release is available."

  if ! systemctl disable --now "${SERVICE_NAME}"; then
    echo "Could not stop ${SERVICE_NAME} during rollback."
    rollback_failed="true"
  fi

  if [[ -L "${CURRENT_LINK}" ]] &&
     ! unlink "${CURRENT_LINK}"; then

    echo "Could not remove the failed release symlink."
    rollback_failed="true"
  fi
fi

if [[ -z "${PREVIOUS_RELEASE}" ]] &&
   [[ "${PLACEHOLDER_WAS_ACTIVE}" == "true" ]]; then

  echo "Restoring placeholder service: ${PLACEHOLDER_SERVICE}"

  if ! systemctl enable --now "${PLACEHOLDER_SERVICE}"; then
    echo "Could not restore ${PLACEHOLDER_SERVICE}."
    rollback_failed="true"
  fi
fi

if [[ -f "${SERVICE_UNIT_PATH}" ]]; then
  systemctl status \
    "${SERVICE_NAME}" \
    --no-pager \
    --full || true

  journalctl \
    -u "${SERVICE_NAME}" \
    -n 100 \
    --no-pager || true
fi

if [[ "${rollback_failed}" == "true" ]]; then
  echo "Rollback completed with errors."
  exit 1
fi

echo "Rollback completed."
