# Device-first Model Runner

Model-Runner is designed for people running inference on their own devices.

The runner should be a tiny local gateway, not a cloud-first service.

## Principle

```text
user device -> local model-runner -> local inference backend
```

Cloud and remote endpoints are optional fallback paths, not the default.

## What runs on the device?

- model-runner gateway
- local config
- local routing policy
- optional local model backend
- optional local logs/cache

## What does not ship by default?

- model weights
- Python
- torch
- CUDA runtime
- bundled inference engine

Users choose their own inference engine.

## Supported local backends

The runner should detect or connect to:

- Ollama on localhost
- llama.cpp server on localhost
- LM Studio local server
- Jan local server
- ONNX local service
- custom localhost endpoint

## Default behavior

The safest default is local-only:

```text
127.0.0.1 only
no public bind
no cloud endpoint
no telemetry
no bundled model
```

## Device profiles

### Laptop / desktop

Recommended:

```text
model-runner native binary + Ollama / llama.cpp / LM Studio
```

### Mac

Recommended distribution:

```text
Model Runner.app / DMG
```

### Linux device

Recommended distribution:

```text
native binary or rootless Podman container
```

### Windows

Recommended distribution:

```text
portable zip or installer later
```

### Edge / IoT

Recommended:

```text
static C binary + local HTTP endpoint
```

## Container role

Containers are useful for reproducibility, but they should not be mandatory for device users.

Use containers for:

- servers
- NAS devices
- homelabs
- Linux desktops
- controlled enterprise installs

Use native binaries for:

- laptops
- consumer devices
- macOS app installs
- low-resource edge devices

## Runtime model

```text
┌──────────────┐
│ User App     │
└──────┬───────┘
       │ localhost HTTP
┌──────▼───────┐
│ Model Runner │ tiny C gateway
└──────┬───────┘
       │ localhost HTTP
┌──────▼───────┐
│ Inference    │ Ollama / llama.cpp / LM Studio / custom
└──────────────┘
```

## Why this is better

- works offline
- keeps data local
- avoids cloud dependency
- small install size
- user controls models
- device can choose best backend
- no vendor lock-in

## Future device features

- backend auto-discovery
- local-only firewall guard
- model registry
- per-device profile
- offline queue
- battery-aware routing
- LAN device discovery
- optional SurrealDB local state
