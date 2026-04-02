#!/bin/bash
set -euo pipefail

REQUIRED_PATHS=("configuration" "modules" "workflows")
for path in "${REQUIRED_PATHS[@]}"; do
  if [ ! -e "$path" ]; then
    echo "Run this script from the Engine directory (missing: $path)."
    exit 1
  fi
done

ASSET_SERVER_PID=""
start_webform_assets() {
  if [ "${WEBFORM_ASSETS:-1}" = "0" ]; then
    return
  fi

  if [ -f "modules/webform/link_assets.sh" ]; then
    bash modules/webform/link_assets.sh || true
  fi

  if [ -f "modules/webform/serve_webform_assets.py" ]; then
    python3 modules/webform/serve_webform_assets.py >/tmp/seyoawe-webform-assets.log 2>&1 &
    ASSET_SERVER_PID=$!
    echo "Started webform asset server on :9000 (pid $ASSET_SERVER_PID)"
  fi
}

cleanup() {
  if [ -n "$ASSET_SERVER_PID" ]; then
    kill "$ASSET_SERVER_PID" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

if [ -z "$1" ]; then
  echo "Usage: $0 <linux / macos>"
  exit 1
fi

start_webform_assets

case "$1" in
  linux)
    echo "Starting Seyoawe Community Edition for Linux..."
    ./seyoawe.linux
    ;;
  macos)
    echo "Starting Seyoawe Community Edition for macOS..."
    ./seyoawe.macos.arm
    ;;
  *)
    echo "Invalid argument. Use 'linux' or 'macos'."
    exit 1
    ;;
esac