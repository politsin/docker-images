#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$#" -gt 0 ]; then
  TARGETS=("$@")
else
  TARGETS=(
    "8.4 2 5"
    "8.5 1 1"
  )
fi

tag_exists() {
  local image="$1"
  local tag="$2"

  docker manifest inspect "${image}:${tag}" >/dev/null 2>&1
}

for target in "${TARGETS[@]}"; do
  read -r version service_build php_build <<<"${target}"

  if [ -z "${version}" ] || [ -z "${service_build}" ] || [ -z "${php_build}" ]; then
    echo "Invalid target '${target}'. Expected 'VERSION SERVICE_BUILD PHP_BUILD'" >&2
    exit 1
  fi

  service_tag="${version}.${service_build}"
  php_tag="${version}.${php_build}"

  if tag_exists "synstd/php-service" "${service_tag}"; then
    echo "Skip php-service:${service_tag}, tag already exists"
  else
    echo "Build php-service:${service_tag}"
    (
      cd "${ROOT_DIR}/php-service"
      VERSION="${version}" BUILD="${service_build}" ./build.sh
    )
  fi

  if tag_exists "synstd/php" "${php_tag}"; then
    echo "Skip php:${php_tag}, tag already exists"
  else
    echo "Build php:${php_tag}"
    (
      cd "${ROOT_DIR}/php"
      VERSION="${version}" BUILD="${php_build}" ./build.sh
    )
  fi
done
