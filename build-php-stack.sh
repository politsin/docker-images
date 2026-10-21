#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$(readlink -f "$0")")/build-lib.sh"
exec 9>"$ROOT_DIR/.php-build.lock"
flock -n 9 || { echo 'Another PHP build is running' >&2; exit 1; }
targets=("$@")
[[ ${#targets[@]} -gt 0 ]] || targets=(
  "8.5 8 10" "8.4 4 7" "8.3 8 11" "8.2 2 2" "8.1 3 302"
  "8.0 2 2" "7.4 2 2" "7.3 1 1" "7.2 2 2" "7.1 1 1"
)
# Fetch once and reuse this exact OS snapshot throughout the run.
if [[ -z "${UBUNTU_IMAGE:-}" ]]; then
  docker pull ubuntu:26.04
  UBUNTU_IMAGE="$(docker image inspect ubuntu:26.04 --format '{{index .RepoDigests 0}}')"
  export UBUNTU_IMAGE
fi
echo "$UBUNTU_IMAGE" | tee "$LOG_DIR/ubuntu-digest.txt"
for target in "${targets[@]}"; do
  [[ "$target" =~ ^(8\.[0-5]|7\.[1-4])[[:space:]]+[0-9]+[[:space:]]+[0-9]+$ ]] || { echo "Expected 'VERSION SERVICE_BUILD PHP_BUILD': $target" >&2; exit 1; }
done
while read -r version service_build php_build; do
  if [[ -f "$LOG_DIR/php-service-$version.done" && -f "$LOG_DIR/php-$version.done" ]] &&
     [[ "$(docker image inspect "synstd/php-service:$version" --format '{{.Id}}' 2>/dev/null || true)" == "$(cat "$LOG_DIR/php-service-$version.done")" ]] &&
     [[ "$(docker image inspect "synstd/php:$version" --format '{{.Id}}' 2>/dev/null || true)" == "$(cat "$LOG_DIR/php-$version.done")" ]]; then
    echo "Already verified/published PHP pair: $version"
    continue
  fi
  export VERSION="$version"
  PHP_PACKAGE_VERSION="$("$ROOT_DIR/wait-php-package.sh" "$version")"
  export PHP_PACKAGE_VERSION
  BUILD="$service_build" build_php_image php-service
  BUILD="$php_build" build_php_image php
done < <(printf '%s\n' "${targets[@]}" | sort -Vr -u)
echo PHP_STACK_COMPLETE | tee "$LOG_DIR/complete"
