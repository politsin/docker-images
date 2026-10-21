#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RELEASE_ID="${RELEASE_ID:-$(date -u +%Y%m%dT%H%M%SZ)}"
LOG_DIR="${LOG_DIR:-${ROOT_DIR}/report/build-${RELEASE_ID}}"
mkdir -p "$LOG_DIR"
export RELEASE_ID LOG_DIR

# Optional build-only transport; predefined Docker proxy args are not image ENV.
configure_build_transport() {
  local -n transport_flags="$1"
  if [[ -n "${BUILD_PROXY:-}" ]]; then
    local bypass="${BUILD_NO_PROXY:-localhost,127.0.0.1,mirror.yandex.ru,archive.ubuntu.com,security.ubuntu.com}"
    transport_flags+=(--network=host
      --build-arg "http_proxy=$BUILD_PROXY" --build-arg "https_proxy=$BUILD_PROXY"
      --build-arg "HTTP_PROXY=$BUILD_PROXY" --build-arg "HTTPS_PROXY=$BUILD_PROXY"
      --build-arg "no_proxy=$bypass" --build-arg "NO_PROXY=$bypass")
  fi
}

# Verify the candidate BEFORE moving or publishing mutable tags.
verify_php() {
  local image="$1" branch="$2"
  if docker image inspect "$image" --format '{{range .Config.Env}}{{println .}}{{end}}' | grep -Eqi '^(http_proxy|https_proxy|no_proxy)='; then
    echo "Temporary build proxy leaked into image environment" >&2
    return 1
  fi
  docker run --rm --entrypoint /usr/local/bin/verify-php-security "$image" "$branch"
  docker run --rm --entrypoint sh "$image" -ec '
    php -v
    php -m
    php -r '\''foreach (["curl", "mysqli", "pdo_mysql", "mbstring", "intl", "gd", "zip", "uploadprogress"] as $ext) {if (!extension_loaded($ext)) {fwrite(STDERR, "Missing $ext\n"); exit(1);}}'\''
    dpkg-query -W "php*-cli" "php*-fpm"
  ' | tee "$LOG_DIR/${image//[\/:]/_}-php.txt"
  case "$branch" in
    8.3|8.4|8.5) docker run --rm --entrypoint php "$image" -r 'exit(extension_loaded("grpc") && extension_loaded("dio") ? 0 : 1);' ;;
    *) docker run --rm --entrypoint php "$image" -r 'exit(!extension_loaded("grpc") && !extension_loaded("dio") ? 0 : 1);' ;;
  esac
}

publish_php() {
  local image="$1" branch="$2" candidate="$3" tag
  local tags=("${branch}-build${RELEASE_ID}" "${branch}-amd64" "$branch")
  [[ "$branch" != 8.5 ]] || tags+=(latest)
  for tag in "${tags[@]}"; do
    docker tag "$candidate" "$image:$tag"
    docker push "$image:$tag" | tee "$LOG_DIR/${image##*/}-${tag}-push.txt"
    docker image inspect "$image:$tag" --format '{{json .RepoDigests}}' >> "$LOG_DIR/digests.txt"
  done
}

build_php_image() {
  local kind="$1" branch="${VERSION:-8.5}" image="synstd/$1" candidate
  candidate="${image}:candidate-${branch}-${RELEASE_ID}"
  local marker="$LOG_DIR/$kind-$branch.done"
  if [[ -f "$marker" ]] && [[ "$(docker image inspect "$image:$branch" --format '{{.Id}}' 2>/dev/null || true)" == "$(cat "$marker")" ]]; then
    echo "Already verified/published: $image:$branch"
    return
  fi
  local flags=(--build-arg "PHP=$branch" --pull=false --progress=plain)
  configure_build_transport flags
  [[ "${NO_CACHE:-0}" != 1 ]] || flags+=(--no-cache)
  if [[ "$kind" == php-service ]]; then
    flags+=(--build-arg "UBUNTU_IMAGE=${UBUNTU_IMAGE:-ubuntu:26.04}" --build-arg "REFRESH=$RELEASE_ID" --build-arg "PHP_PACKAGE_VERSION=${PHP_PACKAGE_VERSION:-latest}")
  fi
  docker build "${flags[@]}" "$ROOT_DIR/$kind" -t "$candidate" 2>&1 | tee "$LOG_DIR/$kind-$branch-build.txt"
  verify_php "$candidate" "$branch"
  if [[ "$kind" == php ]]; then
    docker run --rm --entrypoint sh "$candidate" -ec '
      php-fpm -t
      /usr/sbin/sshd -t
      node --version; npm --version
      gulp --version; eslint --version; stylelint --version; editorconfig-checker --version
      /var/lib/composer/vendor/bin/phpcs --version
      /usr/local/bin/frontend-smoke.sh
    ' 2>&1 | tee "$LOG_DIR/php-$branch-smoke.txt"
  fi
  publish_php "$image" "$branch" "$candidate"
  local runtime debian digest
  runtime=$(docker run --rm --entrypoint php "$candidate" -r 'echo PHP_VERSION;')
  debian=$(docker run --rm --entrypoint dpkg-query "$candidate" -W '-f=${Version}' "php${branch}-cli")
  digest=$(docker image inspect "$candidate" --format '{{range .RepoDigests}}{{println .}}{{end}}' | awk -v prefix="$image@" 'index($0,prefix)==1 {print; exit}')
  test -n "$digest"
  printf '%s\t%s\t%s\t%s\t%s\n' "$branch" "$kind" "$runtime" "$debian" "$digest" >> "$LOG_DIR/published-php.tsv"
  docker image inspect "$candidate" --format '{{.Id}}' > "$marker"
}
