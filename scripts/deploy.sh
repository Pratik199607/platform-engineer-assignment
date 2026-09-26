#!/usr/bin/env bash
set -Eeuo pipefail

APP_NAME="platform"
APP_ROOT="/opt/platform"
RELEASES_DIR="${APP_ROOT}/releases"
CURRENT_LINK="${APP_ROOT}/current"
SOURCE_DIR="${1:-$(pwd)}"

TIMESTAMP="$(date '+%Y%m%d-%H%M%S')"
RELEASE_DIR="${RELEASES_DIR}/${TIMESTAMP}"

echo "========================================"
echo "Platform deployment"
echo "Release: ${TIMESTAMP}"
echo "========================================"

if [[ ! -f "${SOURCE_DIR}/requirements.txt" ]]; then
    echo "ERROR: requirements.txt not found in ${SOURCE_DIR}"
    exit 1
fi

if [[ ! -f "${SOURCE_DIR}/alembic.ini" ]]; then
    echo "ERROR: alembic.ini not found in ${SOURCE_DIR}"
    exit 1
fi

mkdir -p "${RELEASE_DIR}"

echo "[1/8] Copying application..."

rsync -a \
    --delete \
    --exclude ".git" \
    --exclude ".github" \
    --exclude ".venv" \
    --exclude "__pycache__" \
    "${SOURCE_DIR}/" \
    "${RELEASE_DIR}/"

echo "[2/8] Creating Python virtual environment..."

python3.11 -m venv "${RELEASE_DIR}/venv"

echo "[3/8] Installing Python dependencies..."

"${RELEASE_DIR}/venv/bin/pip" install --upgrade pip
"${RELEASE_DIR}/venv/bin/pip" install -r "${RELEASE_DIR}/requirements.txt"

echo "[4/8] Loading database credentials from Secrets Manager..."

source /etc/platform/platform.env

if [[ -z "${DB_SECRET_ARN:-}" ]]; then
    echo "ERROR: DB_SECRET_ARN is not configured"
    exit 1
fi

SECRET_JSON="$(aws secretsmanager get-secret-value \
    --secret-id "${DB_SECRET_ARN}" \
    --query 'SecretString' \
    --output text)"

DB_USERNAME="$(echo "${SECRET_JSON}" | jq -r '.username')"
DB_PASSWORD="$(echo "${SECRET_JSON}" | jq -r '.password')"
DB_HOST="$(echo "${SECRET_JSON}" | jq -r '.host')"
DB_PORT="$(echo "${SECRET_JSON}" | jq -r '.port')"
DB_NAME="$(echo "${SECRET_JSON}" | jq -r '.database')"

export DATABASE_URL="postgresql+psycopg://${DB_USERNAME}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}"

echo "[5/8] Running database migrations..."

sudo -u platform env \
    DATABASE_URL="${DATABASE_URL}" \
    bash -c "cd '${RELEASE_DIR}' && '${RELEASE_DIR}/venv/bin/alembic' upgrade head"

echo "[6/8] Setting release ownership..."

chown -R platform:platform "${RELEASE_DIR}"

echo "[7/8] Switching current release..."

ln -sfn "${RELEASE_DIR}" "${CURRENT_LINK}"

systemctl daemon-reload
systemctl restart "${APP_NAME}"

echo "Waiting for application..."

sleep 5

echo "[8/8] Running health checks..."

if ! curl --fail --silent --show-error \
    --max-time 10 \
    "http://127.0.0.1:8000/api/health/live"; then

    echo ""
    echo "ERROR: Liveness check failed."
    exit 1
fi

if ! curl --fail --silent --show-error \
    --max-time 10 \
    "http://127.0.0.1:8000/api/health/ready"; then

    echo ""
    echo "ERROR: Readiness check failed."
    exit 1
fi

echo ""
echo "========================================"
echo "Deployment successful"
echo "Release: ${RELEASE_DIR}"
echo "========================================"