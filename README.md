# Model-Runner

Device-first local GGUF model runner.

Model-Runner bundles:

- llama.cpp
- llama-server
- GGUF runtime support

This project is designed for running models locally on user devices.

## Philosophy

- local-first
- offline capable
- no Python
- no FastAPI
- no cloud dependency
- simple deployment
- small footprint

## What this is

```text
user/app -> model-runner -> bundled llama-server -> GGUF model
```

## What this is NOT

- cloud inference platform
- distributed GPU serving stack
- Ollama wrapper
- generic proxy layer

## Build

### Podman

```bash
podman build -t model-runner -f Containerfile .
```

## Run

Mount a GGUF model from the host device.

```bash
podman run --rm \
  -p 8080:8080 \
  -v ./models:/models:Z \
  -e MODEL=/models/model.gguf \
  model-runner
```

## API

The container exposes llama-server directly.

### Health

```bash
curl http://localhost:8080/health
```

### Completion

```bash
curl http://localhost:8080/completion \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Hello",
    "n_predict": 128
  }'
```

## Environment Variables

| Variable | Default | Description |
|---|---:|---|
| MODEL | required | path to GGUF model |
| HOST | 0.0.0.0 | bind host |
| PORT | 8080 | bind port |
| CTX_SIZE | 4096 | context size |
| THREADS | 4 | CPU threads |
| GPU_LAYERS | 0 | GPU offload layers |

## Example models

```text
TinyLlama
Qwen
Llama 3
Mistral
Phi
Gemma
DeepSeek GGUF builds
```

## Device-first usage

### macOS

Future distribution:

```text
DMG + native app bundle
```

### Linux

Recommended:

```text
Podman container or native binary
```

### Windows

Planned:

```text
portable executable
```

## Why this exists

Running llama.cpp manually is inconvenient for many device users.

Model-Runner packages llama.cpp into a simple local runtime that can:

- load GGUF models
- expose a localhost API
- work offline
- run locally on-device
- stay lightweight
