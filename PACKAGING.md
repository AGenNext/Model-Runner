# Packaging Strategy

Model-Runner is a tiny gateway. It does not bundle inference or model weights.

## Language choice

C is the lightest practical choice for this project because it can produce a very small native binary with no runtime dependency.

Recommended build targets:

- Linux x86_64
- Linux arm64
- macOS arm64
- macOS x86_64
- Windows x86_64

## Primary distribution: container image

Use container images for server and cloud distribution.

```bash
podman build -t model-runner -f Containerfile .
podman run --rm -p 8080:8080 \
  -e INFERENCE_URL=http://host.containers.internal:11434/api/generate \
  model-runner
```

This keeps the package portable and avoids OS-specific installers.

## macOS distribution: DMG

Use DMG only for macOS users who want a local desktop-style install.

A DMG should include:

```text
Model Runner.app
README.txt
example.env
```

The app should be a small launcher around the native `model-runner` binary.

Recommended macOS flow:

1. Build universal macOS binary:

```bash
clang -O2 -arch arm64 -arch x86_64 -o model-runner src/model-runner.c
```

2. Place binary inside app bundle:

```text
Model Runner.app/Contents/MacOS/model-runner
```

3. Create DMG:

```bash
hdiutil create -volname "Model Runner" \
  -srcfolder "dist/macos" \
  -ov -format UDZO \
  "dist/Model-Runner.dmg"
```

## Recommended release artifacts

For each release, publish:

```text
model-runner-linux-amd64.tar.gz
model-runner-linux-arm64.tar.gz
model-runner-macos-universal.dmg
model-runner-windows-amd64.zip
container image: ghcr.io/AGenNext/model-runner:<version>
```

## Do not bundle models

Model files should not be shipped inside the runner package.
Users should point the runner to their own inference backend.
