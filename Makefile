IMAGE ?= model-runner
PLATFORMS ?= linux/amd64,linux/arm64

.PHONY: image launcher

image:
	podman build -t $(IMAGE) -f Containerfile .

image-docker:
	docker build -t $(IMAGE) -f Containerfile .

launcher:
	cd launcher && cargo build --release

run:
	podman run --rm -p 8080:8080 -v ./models:/models -e MODEL_DIR=/models $(IMAGE)
