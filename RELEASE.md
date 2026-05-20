# Release Readiness

Model-Runner is the AGenNext model execution runtime.

## Boundary

Model-Runner executes models. It does not orchestrate capabilities.

## Release Requirements

- Explicit model loading
- Explicit artifact paths
- Reproducible execution
- Airgap-compatible runtime
- Minimal dependency surface
- No hidden downloads

## Primitive Rule

Model execution must be explicit, inspectable, and replaceable.
