#!/bin/sh
set -eu

MODEL="${MODEL:-}"
HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-8080}"
CTX_SIZE="${CTX_SIZE:-4096}"
THREADS="${THREADS:-4}"
GPU_LAYERS="${GPU_LAYERS:-0}"

if [ -z "$MODEL" ]; then
  echo "MODEL environment variable is required"
  echo "Example: -e MODEL=/models/model.gguf"
  exit 1
fi

if [ ! -f "$MODEL" ]; then
  echo "Model file not found: $MODEL"
  exit 1
fi

exec llama-server \
  --model "$MODEL" \
  --host "$HOST" \
  --port "$PORT" \
  --ctx-size "$CTX_SIZE" \
  --threads "$THREADS" \
  --gpu-layers "$GPU_LAYERS"
