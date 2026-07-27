#!/bin/sh
set -eu

APP_NAME="${APP_NAME:-devsecops-app}"
DATA_DIR="${DATA_DIR:-/data}"

echo "Starting ${APP_NAME}..."

# Add project-specific preparation or validation above the final exec.
if [ ! -d "${DATA_DIR}" ]; then
  mkdir -p "${DATA_DIR}"
fi

exec "$@"
