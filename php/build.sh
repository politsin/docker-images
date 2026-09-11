#!/bin/bash

set -euo pipefail

IMAGE="synstd/php"
VERSION="${VERSION:-8.4}"
BUILD="${BUILD:-3}"
NO_CACHE="${NO_CACHE:-1}"

BUILD_FLAGS=(--pull --build-arg PHP="$VERSION")
if [ "$NO_CACHE" = "1" ]; then
  BUILD_FLAGS+=(--no-cache)
fi

docker build "${BUILD_FLAGS[@]}" . -t "${IMAGE}"

docker tag "${IMAGE}" "${IMAGE}:${VERSION}"
docker tag "${IMAGE}" "${IMAGE}:${VERSION}-amd64"
docker tag "${IMAGE}" "${IMAGE}:${VERSION}.${BUILD}"

docker push "${IMAGE}:${VERSION}-amd64"
docker push "${IMAGE}:${VERSION}.${BUILD}"
docker push "${IMAGE}:${VERSION}"
