#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

python3 -m pip install --user --upgrade pip
python3 -m pip install --user -r "$SCRIPT_DIR/requirements.txt" pyinstaller "jsonschema>=4.18"

"$HOME/.local/bin/pyinstaller" --clean --onefile --name sawectl \
  --add-data "$SCRIPT_DIR/dsl.schema.json:." \
  --add-data "$SCRIPT_DIR/module.schema.json:." \
  "$SCRIPT_DIR/sawectl.py"

mkdir -p "$SCRIPT_DIR/binaries/linux"
cp "$SCRIPT_DIR/dist/sawectl" "$SCRIPT_DIR/binaries/linux/sawectl"
chmod +x "$SCRIPT_DIR/binaries/linux/sawectl"

echo "Built Linux CLI binary at: $SCRIPT_DIR/binaries/linux/sawectl"
