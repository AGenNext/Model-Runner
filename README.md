# Model-Runner

Ultra-lightweight model runner gateway.

This project does **not** bundle inference. The user selects the inference backend.

The runner is only a tiny containerized control/proxy layer for:

- local llama.cpp server
- Ollama
- vLLM
- ONNX service
- remote API-compatible inference
- any HTTP inference endpoint

## Why this design?

Model inference is heavy. Distribution should stay light.

So this project ships a tiny runner and lets users plug in their own inference engine.

```text
client -> model-runner -> user-selected inference backend
```

## Build with Podman

```bash
podman build -t model-runner -f Containerfile .
```

## Run

```bash
podman run --rm -p 8080:8080 \
  -e INFERENCE_URL=http://host.containers.internal:11434/api/generate \
  model-runner
```

## API

### Health

```bash
curl http://localhost:8080/health
```

### Generate

```bash
curl -X POST http://localhost:8080/generate \
  -H 'Content-Type: application/json' \
  -d '{"model":"llama3.2","prompt":"Hello"}'
```

The body is passed through to the configured inference backend.

## Environment

| Variable | Default | Description |
|---|---:|---|
| HOST | 0.0.0.0 | bind address |
| PORT | 8080 | bind port |
| INFERENCE_URL | empty | user-selected inference endpoint |
| MOCK | 0 | set to 1 for mock responses |

## Philosophy

- No Python
- No FastAPI
- No bundled model
- No forced backend
- Containerized with Podman
- Small C gateway
- User owns inference choice
