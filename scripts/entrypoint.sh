#!/bin/sh
set -eu

: "${MODEL:?MODEL is required. Example: -e MODEL=/models/model.gguf}"

HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-8080}"
CTX_SIZE="${CTX_SIZE:-4096}"
THREADS="${THREADS:-4}"
BATCH_SIZE="${BATCH_SIZE:-512}"
UBATCH_SIZE="${UBATCH_SIZE:-512}"
GPU_LAYERS="${GPU_LAYERS:-0}"
PARALLEL="${PARALLEL:-1}"

if [ ! -f "$MODEL" ]; then
  echo "model not found: $MODEL" >&2
  exit 1
fi

set -- llama-server \
  --model "$MODEL" \
  --host "$HOST" \
  --port "$PORT" \
  --ctx-size "$CTX_SIZE" \
  --threads "$THREADS" \
  --batch-size "$BATCH_SIZE" \
  --ubatch-size "$UBATCH_SIZE" \
  --gpu-layers "$GPU_LAYERS" \
  --parallel "$PARALLEL"

[ "${FLASH_ATTN:-0}" = "1" ] && set -- "$@" --flash-attn
[ "${MLOCK:-0}" = "1" ] && set -- "$@" --mlock
[ "${NO_MMAP:-0}" = "1" ] && set -- "$@" --no-mmap
[ -n "${CHAT_TEMPLATE:-}" ] && set -- "$@" --chat-template "$CHAT_TEMPLATE"
[ -n "${ALIAS:-}" ] && set -- "$@" --alias "$ALIAS"

# Optional escape hatch for advanced llama-server flags.
# Keep this simple for the lightest runner. Quote carefully when using it.
if [ -n "${EXTRA_ARGS:-}" ]; then
  # shellcheck disable=SC2086
  set -- "$@" $EXTRA_ARGS
fi

exec "$@"
