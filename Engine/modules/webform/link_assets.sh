#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$SCRIPT_DIR/build/dist"

if [ ! -d "$DIST_DIR" ]; then
  echo "Missing dist directory: $DIST_DIR"
  echo "Build the webform bundle first."
  exit 1
fi

cp -f "$DIST_DIR/webform_bundle.js" "$SCRIPT_DIR/webform_bundle.js"
cp -f "$DIST_DIR/webform_bundle.css" "$SCRIPT_DIR/webform_bundle.css"
cp -f "$DIST_DIR/custom.css" "$SCRIPT_DIR/custom.css"

rm -rf "$SCRIPT_DIR/configs"
cp -R "$DIST_DIR/configs" "$SCRIPT_DIR/configs"

echo "Webform assets linked into modules/webform/"
