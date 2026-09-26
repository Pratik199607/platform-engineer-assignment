#!/usr/bin/env bash

set -Eeuo pipefail

APP_ROOT="/opt/platform"
RELEASES_DIR="${APP_ROOT}/releases"
CURRENT_LINK="${APP_ROOT}/current"

if [[ ! -L "${CURRENT_LINK}" ]]; then
    echo "No current release is configured."
    exit 1
fi

CURRENT_RELEASE="$(readlink -f "${CURRENT_LINK}")"

echo "Current release:"
echo "${CURRENT_RELEASE}"

PREVIOUS_RELEASE="$(
    find "${RELEASES_DIR}" \
        -mindepth 1 \
        -maxdepth 1 \
        -type d \
        -printf '%T@ %p\n' |
    sort -nr |
    awk '{$1=""; sub(/^ /,""); print}' |
    grep -v "^${CURRENT_RELEASE}$" |
    head -n 1
)"

if [[ -z "${PREVIOUS_RELEASE}" ]]; then
    echo "No previous release found."
    exit 1
fi

echo ""
echo "Previous release:"
echo "${PREVIOUS_RELEASE}"

echo ""
echo "Switching to previous release..."

sudo ln -sfn "${PREVIOUS_RELEASE}" "${CURRENT_LINK}"

echo ""
echo "Restarting application..."

sudo systemctl restart platform

sleep 5

echo ""
echo "Running health check..."

curl \
    --fail \
    --silent \
    --show-error \
    http://127.0.0.1:8000/api/health/live

echo ""
echo "Rollback successful."
