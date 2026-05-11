#!/usr/bin/env bash
set -euo pipefail

if [[ -f biome.json ]]; then
  npx @biomejs/biome check --write .
else
  echo "biome.json not found; skipping Biome autofix"
fi
