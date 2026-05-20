#!/usr/bin/env bash

set -e

echo "[model-runner] checking bun runtime"

if ! command -v bun >/dev/null 2>&1; then
  echo "[model-runner] bun not found"
  echo "[model-runner] installing bun"

  curl -fsSL https://bun.sh/install | bash

  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
fi

cd "$(dirname "$0")"

bun install
bun run src/index.ts
