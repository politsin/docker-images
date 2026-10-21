#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$(readlink -f "$0")")/../build-lib.sh"
VERSION="${VERSION:-8.5}"
BUILD="${BUILD:?Set the next numeric BUILD for this PHP branch}"
[[ "$VERSION" =~ ^8\.[0-5]$ && "$BUILD" =~ ^[0-9]+$ ]] || { echo 'Invalid VERSION or BUILD' >&2; exit 1; }
base=synstd/php-service
case "$VERSION" in 8.3|8.5) base=synstd/php ;; esac
verify_php "$base:$VERSION" "$VERSION"
image=synstd/s3-dockup
flags=(--pull=false --progress=plain --build-arg "PHP=$VERSION" --build-arg "BASE_IMAGE=$base")
configure_build_transport flags
docker build "${flags[@]}" -t "$image" "$ROOT_DIR/backup"
verify_php "$image" "$VERSION"
docker run --rm --network none --user www-data "$image" echo
docker run --rm --network none --entrypoint sh "$image" -ec '
  mydumper --version
  aws --version
  composer check-platform-reqs --no-dev -d /opt/console
'
for tag in "$VERSION.$BUILD" "$VERSION"; do
  docker tag "$image" "$image:$tag"
  docker push "$image:$tag"
done
