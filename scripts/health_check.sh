#!/usr/bin/env bash

set -Eeuo pipefail


HEALTH_URL="${HEALTH_URL:-http://127.0.0.1:8000/api/health/live}"


echo "Checking application health..."


HTTP_STATUS="$(
    curl \
        --silent \
        --output /dev/null \
        --write-out "%{http_code}" \
        --max-time 10 \
        "${HEALTH_URL}"
)"


if [[ "${HTTP_STATUS}" == "200" ]]; then

    echo "Health check passed."

    echo "HTTP status: ${HTTP_STATUS}"

    exit 0

fi


echo "Health check failed."

echo "HTTP status: ${HTTP_STATUS}"

exit 1