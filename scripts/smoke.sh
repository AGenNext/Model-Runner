#!/bin/sh
set -eu

IMAGE="${IMAGE:-model-runner}"
MODEL_DIR="${MODEL_DIR:-./models}"
PORT="${PORT:-8080}"
RUNTIME="${RUNTIME:-podman}"

if ! command -v "$RUNTIME" >/dev/null 2>&1; then
  echo "runtime not found: $RUNTIME" >&2
  exit 1
fi

if ! ls "$MODEL_DIR"/*.gguf >/dev/null 2>&1; then
  echo "no .gguf model found in $MODEL_DIR" >&2
  exit 1
fi

$RUNTIME run --rm -d \
  --name model-runner-smoke \
  -p "$PORT:8080" \
  -v "$(pwd)/$MODEL_DIR:/models" \
  -e MODEL_DIR=/models \
  "$IMAGE"

cleanup() {
  $RUNTIME rm -f model-runner-smoke >/dev/null 2>&1 || true
}
trap cleanup EXIT

sleep 3

curl -fsS "http://127.0.0.1:$PORT/health" >/dev/null

echo "ok"
