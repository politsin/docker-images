#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$(readlink -f "$0")")/build-lib.sh"
exec 9>"$ROOT_DIR/.php-build.lock"
flock -n 9 || { echo 'Another PHP build is running' >&2; exit 1; }
versions=("$@")
[[ ${#versions[@]} -gt 0 ]] || versions=(8.5 8.4 8.3 8.2 8.1 8.0 7.4 7.3 7.2 7.1)
# Fetch once and reuse this exact OS snapshot throughout the run.
if [[ -z "${UBUNTU_IMAGE:-}" ]]; then
  docker pull ubuntu:26.04
  UBUNTU_IMAGE="$(docker image inspect ubuntu:26.04 --format '{{index .RepoDigests 0}}')"
  export UBUNTU_IMAGE
fi
echo "$UBUNTU_IMAGE" | tee "$LOG_DIR/ubuntu-digest.txt"
for version in "${versions[@]}"; do
  [[ "$version" =~ ^(8\.[0-5]|7\.[1-4])$ ]] || { echo "Invalid version $version" >&2; exit 1; }
done
while read -r version; do
  export VERSION="$version"
  PHP_PACKAGE_VERSION="$("$ROOT_DIR/wait-php-package.sh" "$version")"
  export PHP_PACKAGE_VERSION
  build_php_image php-service
  build_php_image php
done < <(printf '%s\n' "${versions[@]}" | sort -Vr -u)
echo PHP_STACK_COMPLETE | tee "$LOG_DIR/complete"
