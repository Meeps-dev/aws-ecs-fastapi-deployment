#!/usr/bin/env bash

set -euo pipefail

required_variables=(
  RELEASE_SHA
  SOURCE_DIR
  AWS_REGION
  RDS_SECRET_ARN
  DB_HOST
  DB_PORT
  DB_NAME
  APP_PORT
  EXPECTED_PORT
)

for variable_name in "${required_variables[@]}"; do
  if [[ -z "${!variable_name:-}" ]]; then
    echo "Required variable is missing: ${variable_name}"
    exit 1
  fi
done

if ((EUID != 0)); then
  echo "deploy.sh must run as root."
  exit 1
fi

if [[ ! "${RELEASE_SHA}" =~ ^[0-9a-f]{40}$ ]]; then
  echo "RELEASE_SHA must be a full lowercase Git commit SHA."
  exit 1
fi

validate_port() {
  local variable_name="$1"
  local port_value="${!variable_name}"

  if [[ ! "${port_value}" =~ ^[0-9]+$ ]] ||
     ((10#${port_value} < 1 || 10#${port_value} > 65535)); then

    echo "${variable_name} must be an integer from 1 through 65535."
    exit 1
  fi
}

for port_variable in DB_PORT APP_PORT EXPECTED_PORT; do
  validate_port "${port_variable}"
done

if [[ "${APP_PORT}" != "${EXPECTED_PORT}" ]]; then
  echo "APP_PORT must match EXPECTED_PORT."
  exit 1
fi

SOURCE_DIR="$(
  cd "${SOURCE_DIR}"
  pwd
)"

APP_NAME="users-posts-api"
APP_USER="users-posts-api"
APP_GROUP="users-posts-api"

APP_ROOT="/opt/${APP_NAME}"
RELEASES_DIR="${APP_ROOT}/releases"
RELEASE_DIR="${RELEASES_DIR}/${RELEASE_SHA}"
STAGING_DIR="${RELEASES_DIR}/.${RELEASE_SHA}.staging"
CURRENT_LINK="${APP_ROOT}/current"
VENV_DIR="${RELEASE_DIR}/.venv"
DEPLOY_LOCK_PATH="/var/lock/${APP_NAME}-deploy.lock"

SERVICE_NAME="${APP_NAME}.service"
SERVICE_UNIT_SOURCE="${SOURCE_DIR}/deploy/${SERVICE_NAME}"
SERVICE_UNIT_PATH="/etc/systemd/system/${SERVICE_NAME}"
SERVICE_UNIT_BACKUP="${APP_ROOT}/.${SERVICE_NAME}.rollback"
PLACEHOLDER_SERVICE="meeps-backend.service"

HEALTH_CHECK_SCRIPT="${SOURCE_DIR}/scripts/health-check.sh"
ROLLBACK_SCRIPT="${SOURCE_DIR}/scripts/rollback.sh"

if ! command -v flock >/dev/null 2>&1; then
  echo "flock is required to serialize deployments."
  exit 1
fi

exec 9>"${DEPLOY_LOCK_PATH}"

if ! flock -n 9; then
  echo "Another ${APP_NAME} deployment is already running."
  exit 1
fi

required_files=(
  "${SERVICE_UNIT_SOURCE}"
  "${HEALTH_CHECK_SCRIPT}"
  "${ROLLBACK_SCRIPT}"
  "${SOURCE_DIR}/requirements.txt"
  "${SOURCE_DIR}/alembic.ini"
)

for required_file in "${required_files[@]}"; do
  if [[ ! -f "${required_file}" ]]; then
    echo "Required deployment file is missing: ${required_file}"
    exit 1
  fi
done

previous_release=""
switched_release="false"
placeholder_was_active="false"
service_unit_changed="false"

if systemctl is-active --quiet "${PLACEHOLDER_SERVICE}"; then
  placeholder_was_active="true"
fi

if [[ -L "${CURRENT_LINK}" ]]; then
  previous_release="$(readlink -f "${CURRENT_LINK}")"
fi

rollback_and_exit() {
  local exit_code="$1"

  trap - ERR INT TERM
  set +e

  PREVIOUS_RELEASE="${previous_release}" \
  SWITCHED_RELEASE="${switched_release}" \
  PLACEHOLDER_WAS_ACTIVE="${placeholder_was_active}" \
  CURRENT_LINK="${CURRENT_LINK}" \
  SERVICE_NAME="${SERVICE_NAME}" \
  SERVICE_UNIT_PATH="${SERVICE_UNIT_PATH}" \
  SERVICE_UNIT_BACKUP="${SERVICE_UNIT_BACKUP}" \
  SERVICE_UNIT_CHANGED="${service_unit_changed}" \
  PLACEHOLDER_SERVICE="${PLACEHOLDER_SERVICE}" \
  EXPECTED_PORT="${EXPECTED_PORT}" \
  HEALTH_CHECK_SCRIPT="${HEALTH_CHECK_SCRIPT}" \
    bash "${ROLLBACK_SCRIPT}" || true

  exit "${exit_code}"
}

rollback_on_error() {
  local exit_code=$?

  rollback_and_exit "${exit_code}"
}

rollback_on_interrupt() {
  echo "Deployment interrupted."
  rollback_and_exit 130
}

rollback_on_terminate() {
  echo "Deployment terminated."
  rollback_and_exit 143
}

trap rollback_on_error ERR
trap rollback_on_interrupt INT
trap rollback_on_terminate TERM

echo "Installing required operating-system packages."

dnf install -y \
  python3.12 \
  python3.12-pip

command -v aws
command -v curl
command -v python3.12

getent group "${APP_GROUP}" >/dev/null 2>&1 ||
  groupadd --system "${APP_GROUP}"

id -u "${APP_USER}" >/dev/null 2>&1 ||
  useradd \
    --system \
    --gid "${APP_GROUP}" \
    --home-dir "${APP_ROOT}" \
    --shell /sbin/nologin \
    "${APP_USER}"

install -d \
  -o "${APP_USER}" \
  -g "${APP_GROUP}" \
  -m 0755 \
  "${APP_ROOT}" \
  "${RELEASES_DIR}"

if [[ -e "${RELEASE_DIR}" ]] &&
   [[ ! -d "${RELEASE_DIR}" ]]; then

  echo "Release path exists but is not a directory: ${RELEASE_DIR}"
  false
fi

if [[ ! -d "${RELEASE_DIR}" ]]; then
  rm -rf "${STAGING_DIR}"

  install -d \
    -o "${APP_USER}" \
    -g "${APP_GROUP}" \
    -m 0755 \
    "${STAGING_DIR}"

  cp -a "${SOURCE_DIR}/." "${STAGING_DIR}/"

  mv "${STAGING_DIR}" "${RELEASE_DIR}"
else
  echo "Release ${RELEASE_SHA} already exists; reusing its immutable source."
fi

chmod 0755 \
  "${RELEASE_DIR}/scripts/deploy.sh" \
  "${RELEASE_DIR}/scripts/health-check.sh" \
  "${RELEASE_DIR}/scripts/rollback.sh"

echo "Retrieving the RDS-managed secret."

SECRET_JSON="$(
  aws secretsmanager get-secret-value \
    --secret-id "${RDS_SECRET_ARN}" \
    --region "${AWS_REGION}" \
    --query SecretString \
    --output text
)"

export SECRET_JSON
export DB_HOST
export DB_PORT
export DB_NAME

DATABASE_URL="$(
  python3.12 <<'PYTHON'
import json
import os
from urllib.parse import quote

secret = json.loads(os.environ["SECRET_JSON"])

username = quote(secret["username"], safe="")
password = quote(secret["password"], safe="")
host = os.environ["DB_HOST"]
port = os.environ["DB_PORT"]
database = os.environ["DB_NAME"]

print(
    f"postgresql://{username}:{password}"
    f"@{host}:{port}/{database}"
)
PYTHON
)"

unset SECRET_JSON

install \
  -o "${APP_USER}" \
  -g "${APP_GROUP}" \
  -m 0600 \
  /dev/null \
  "${RELEASE_DIR}/.env"

cat > "${RELEASE_DIR}/.env" <<EOF
DATABASE_URL=${DATABASE_URL}
HOST=0.0.0.0
PORT=${APP_PORT}
EOF

chown -R "${APP_USER}:${APP_GROUP}" "${RELEASE_DIR}"
chmod 0600 "${RELEASE_DIR}/.env"

if [[ ! -x "${VENV_DIR}/bin/python" ]]; then
  python3.12 -m venv "${VENV_DIR}"
fi

"${VENV_DIR}/bin/python" \
  -m pip install \
  --upgrade pip

"${VENV_DIR}/bin/python" \
  -m pip install \
  --no-cache-dir \
  -r "${RELEASE_DIR}/requirements.txt"

chown -R "root:${APP_GROUP}" "${VENV_DIR}"
chmod -R u=rwX,g=rX,o= "${VENV_DIR}"

echo "Running Alembic migrations."

pushd "${RELEASE_DIR}" >/dev/null

DATABASE_URL="${DATABASE_URL}" \
  "${VENV_DIR}/bin/alembic" upgrade head

popd >/dev/null

rm -f "${SERVICE_UNIT_BACKUP}"

if [[ -f "${SERVICE_UNIT_PATH}" ]]; then
  install \
    -o root \
    -g root \
    -m 0644 \
    "${SERVICE_UNIT_PATH}" \
    "${SERVICE_UNIT_BACKUP}"
fi

service_unit_changed="true"

install \
  -o root \
  -g root \
  -m 0644 \
  "${RELEASE_DIR}/deploy/${SERVICE_NAME}" \
  "${SERVICE_UNIT_PATH}"

echo "Stopping the temporary placeholder backend."

if systemctl cat "${PLACEHOLDER_SERVICE}" >/dev/null 2>&1; then
  systemctl disable --now "${PLACEHOLDER_SERVICE}"
fi

ln -sfn "${RELEASE_DIR}" "${CURRENT_LINK}"
switched_release="true"

systemctl daemon-reload
systemctl enable "${SERVICE_NAME}"
systemctl restart "${SERVICE_NAME}"

HEALTH_CHECK_ATTEMPTS=30 \
HEALTH_CHECK_INTERVAL_SECONDS=5 \
  bash \
    "${HEALTH_CHECK_SCRIPT}" \
    "http://127.0.0.1:${EXPECTED_PORT}/health"

echo "Testing the database-backed users endpoint."

curl \
  --connect-timeout 3 \
  --max-time 10 \
  -fsS \
  -- \
  "http://127.0.0.1:${EXPECTED_PORT}/users/" \
  >/dev/null

echo "Deployment succeeded."
echo "Release: ${RELEASE_SHA}"

current_release="$(readlink -f "${CURRENT_LINK}")"
echo "Current: ${current_release}"

systemctl status \
  "${SERVICE_NAME}" \
  --no-pager \
  --full

rm -f "${SERVICE_UNIT_BACKUP}" || true
trap - ERR INT TERM
