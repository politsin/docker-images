#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$(readlink -f "$0")")/../build-lib.sh"
exec 9>"$ROOT_DIR/.dockup-build.lock"
flock -n 9 || { echo 'Another dockup build is running' >&2; exit 1; }
versions=("$@")
[[ ${#versions[@]} -gt 0 ]] || versions=(8.5 8.3 8.1)
while read -r branch; do
  [[ "$branch" =~ ^(8\.[0-5]|7\.[1-4])$ ]] || { echo "Invalid PHP: $branch" >&2; exit 1; }
  base=synstd/php-service
  case "$branch" in 8.3|8.5) base=synstd/php ;; esac
  verify_php "$base:$branch" "$branch"
  image=synstd/s3-dockup
  candidate="$image:candidate-$branch-$RELEASE_ID"
  marker="$LOG_DIR/dockup-$branch.done"
  base_id=$(docker image inspect "$base:$branch" --format '{{.Id}}')
  if [[ -f "$marker" ]]; then
    read -r published_id published_base_id < "$marker"
    current_id=$(docker image inspect "$image:$branch" --format '{{.Id}}' 2>/dev/null || true)
    if [[ "$published_id" == "$current_id" && "$published_base_id" == "$base_id" ]]; then
      echo "Already verified/published: $image:$branch"
      continue
    fi
  fi
  flags=(--pull=false --progress=plain --build-arg "PHP=$branch" --build-arg "BASE_IMAGE=$base")
  configure_build_transport flags
  [[ "${NO_CACHE:-0}" != 1 ]] || flags+=(--no-cache)
  docker build "${flags[@]}" -t "$candidate" "$ROOT_DIR/backup" 2>&1 | tee "$LOG_DIR/dockup-$branch-build.txt"
  verify_php "$candidate" "$branch"
  docker run --rm --network none --user www-data "$candidate" echo | tee "$LOG_DIR/dockup-$branch-smoke.txt"
  docker run --rm --network none --entrypoint sh "$candidate" -ec '
    mydumper --version
    aws --version
    composer check-platform-reqs --no-dev -d /opt/console
  ' 2>&1 | tee -a "$LOG_DIR/dockup-$branch-smoke.txt"
  for tag in "$branch-build$RELEASE_ID" "$branch"; do
    docker tag "$candidate" "$image:$tag"
    docker push "$image:$tag" | tee "$LOG_DIR/dockup-$tag-push.txt"
    docker image inspect "$image:$tag" --format '{{json .RepoDigests}}' >> "$LOG_DIR/digests.txt"
  done
  printf '%s %s\n' "$(docker image inspect "$candidate" --format '{{.Id}}')" "$base_id" > "$marker"
done < <(printf '%s\n' "${versions[@]}" | sort -Vr -u)
echo DOCKUP_COMPLETE | tee "$LOG_DIR/dockup-complete"
