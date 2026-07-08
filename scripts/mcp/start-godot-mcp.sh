#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
if [[ ! -f "node_modules/@satelliteoflove/godot-mcp/dist/cli.js" ]]; then
  echo "[godot-mcp] node_modules missing. Run: npm install" >&2
  exit 1
fi
exec node "node_modules/@satelliteoflove/godot-mcp/dist/cli.js"
