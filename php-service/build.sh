#!/bin/bash

set -euo pipefail

IMAGE="synstd/php-service"
VERSION="${VERSION:-8.3}"
BUILD="${BUILD:-1}"

if docker build --build-arg PHP="$VERSION" . -t "${IMAGE}" ; then
  docker tag "${IMAGE}" "${IMAGE}:${VERSION}"
  docker tag "${IMAGE}" "${IMAGE}:${VERSION}-amd64"
  docker tag "${IMAGE}" "${IMAGE}:${VERSION}.${BUILD}"

  docker push "${IMAGE}:${VERSION}-amd64"
  docker push "${IMAGE}:${VERSION}.${BUILD}"
  docker push "${IMAGE}:${VERSION}"
fi
