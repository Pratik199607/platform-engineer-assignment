#!/usr/bin/env bash

set -Eeuo pipefail


APP_NAME="platform"

APP_ROOT="/opt/platform"

RELEASES_DIR="${APP_ROOT}/releases"

CURRENT_LINK="${APP_ROOT}/current"

SOURCE_DIR="${1:-$(pwd)}"

TIMESTAMP="$(date '+%Y%m%d-%H%M%S')"

RELEASE_DIR="${RELEASES_DIR}/${TIMESTAMP}"


echo "============================================"
echo "Platform Application Deployment"
echo "============================================"

echo "Source: ${SOURCE_DIR}"

echo "Release: ${TIMESTAMP}"


echo ""
echo "[1/9] Creating release directory..."


sudo mkdir -p \
    "${RELEASE_DIR}"


echo ""
echo "[2/9] Copying application..."


sudo rsync \
    -a \
    --delete \
    --exclude ".git" \
    --exclude ".github" \
    --exclude ".venv" \
    "${SOURCE_DIR}/" \
    "${RELEASE_DIR}/"


echo ""
echo "[3/9] Creating Python virtual environment..."


sudo python3 -m venv \
    "${RELEASE_DIR}/venv"


echo ""
echo "[4/9] Installing Python dependencies..."


sudo "${RELEASE_DIR}/venv/bin/pip" \
    install \
    --upgrade pip


sudo "${RELEASE_DIR}/venv/bin/pip" \
    install \
    -r "${RELEASE_DIR}/requirements.txt"


echo ""
echo "[5/9] Setting release permissions..."


sudo chown \
    -R platform:platform \
    "${RELEASE_DIR}"


echo ""
echo "[6/9] Running database migrations..."


sudo -u platform \
    bash -c "
        cd '${RELEASE_DIR}' &&
        source /etc/platform/platform.env &&
        '${RELEASE_DIR}/venv/bin/alembic' upgrade head
    "


echo ""
echo "[7/9] Switching current release..."


sudo ln -sfn \
    "${RELEASE_DIR}" \
    "${CURRENT_LINK}"


echo ""
echo "[8/9] Restarting application..."


sudo systemctl restart \
    "${APP_NAME}"


echo ""
echo "[9/9] Running health check..."


sleep 5


if sudo \
    -u platform \
    bash -c "
        curl \
            --fail \
            --silent \
            --show-error \
            http://127.0.0.1:8000/api/health/live
    "
then

    echo ""
    echo "============================================"
    echo "Deployment successful"
    echo "Release: ${TIMESTAMP}"
    echo "============================================"

else

    echo ""
    echo "============================================"
    echo "Deployment health check FAILED"
    echo "============================================"

    exit 1

fi