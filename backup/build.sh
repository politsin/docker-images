#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$(readlink -f "$0")")/../build-lib.sh"
versions=("$@")
[[ ${#versions[@]} -gt 0 ]] || versions=(8.5 8.3 8.1)
while read -r branch; do
  [[ "$branch" =~ ^(8\.[0-5]|7\.[1-4])$ ]] || { echo "Invalid PHP: $branch" >&2; exit 1; }
  base=synstd/php-service
  case "$branch" in 8.3|8.5) base=synstd/php ;; esac
  verify_php "$base:$branch" "$branch"
  image=synstd/s3-dockup
  candidate="$image:candidate-$branch-$RELEASE_ID"
  flags=(--pull=false --progress=plain --build-arg "PHP=$branch" --build-arg "BASE_IMAGE=$base")
  [[ "${NO_CACHE:-0}" != 1 ]] || flags+=(--no-cache)
  docker build "${flags[@]}" -t "$candidate" "$ROOT_DIR/backup" 2>&1 | tee "$LOG_DIR/dockup-$branch-build.txt"
  verify_php "$candidate" "$branch"
  docker run --rm "$candidate" echo | tee "$LOG_DIR/dockup-$branch-smoke.txt"
  for tag in "$branch-build$RELEASE_ID" "$branch"; do
    docker tag "$candidate" "$image:$tag"
    docker push "$image:$tag" | tee "$LOG_DIR/dockup-$tag-push.txt"
    docker image inspect "$image:$tag" --format '{{json .RepoDigests}}' >> "$LOG_DIR/digests.txt"
  done
done < <(printf '%s\n' "${versions[@]}" | sort -Vr -u)
echo DOCKUP_COMPLETE | tee "$LOG_DIR/dockup-complete"
