FROM docker.io/library/alpine:3.20 AS build

ARG LLAMA_CPP_REF=master

RUN apk add --no-cache build-base cmake git

WORKDIR /src
RUN git clone --depth 1 --branch ${LLAMA_CPP_REF} https://github.com/ggml-org/llama.cpp.git llama.cpp

WORKDIR /src/llama.cpp
RUN cmake -B build \
    -DGGML_NATIVE=OFF \
    -DGGML_OPENMP=OFF \
    -DLLAMA_CURL=OFF \
    -DCMAKE_BUILD_TYPE=MinSizeRel \
 && cmake --build build --config MinSizeRel --target llama-server -j$(nproc)

FROM docker.io/library/alpine:3.20

COPY --from=build /src/llama.cpp/build/bin/llama-server /usr/local/bin/llama-server
COPY scripts/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 8080
VOLUME ["/models"]

ENTRYPOINT ["/entrypoint.sh"]
