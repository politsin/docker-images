#!/usr/bin/env bash
set -euo pipefail
branch="$1"
[[ "$branch" =~ ^(8\.[0-5]|7\.[1-4])$ ]] || exit 2
root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
locked_version=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get(sys.argv[2],{}).get("version",""))' "$root_dir/php-service/security-sources.json" "$branch")
if [[ -n "$locked_version" ]]; then
  echo "Using checksum-locked successful noble/amd64 vendor artifacts for PHP $branch" >&2
  printf '%s\n' "$locked_version"
  exit 0
fi
work=$(mktemp -d /tmp/php-package-preflight.XXXXXX)
trap 'rm -rf "$work"' EXIT
deadline=$((SECONDS + ${PACKAGE_WAIT_SECONDS:-3600}))
minimum=""
case "$branch" in
  8.5) minimum=8.5.12 ;; 8.4) minimum=8.4.27 ;;
  8.3) minimum=8.3.36 ;; 8.2) minimum=8.2.35 ;;
esac
while true; do
  if curl -4 --connect-timeout 10 --max-time 45 -fsSL \
    'http://ppa.launchpadcontent.net/ondrej/php/ubuntu/dists/noble/main/binary-amd64/Packages.gz' -o "$work/Packages.gz"; then
    stanza=$(gzip -dc "$work/Packages.gz" | awk -v p="php$branch-common" 'BEGIN{RS="";FS="\n"} $1=="Package: "p{print}')
    version=$(printf '%s\n' "$stanza" | sed -n 's/^Version: //p')
    ready=0
    if [[ -n "$version" && -n "$minimum" ]]; then
      dpkg --compare-versions "$version" ge "$minimum" && ready=1
    elif [[ -n "$version" ]]; then
      filename=$(printf '%s\n' "$stanza" | sed -n 's/^Filename: //p')
      if curl -4 --connect-timeout 10 --max-time 45 -fsSL "http://ppa.launchpadcontent.net/ondrej/php/ubuntu/$filename" -o "$work/common.deb"; then
        dpkg-deb -x "$work/common.deb" "$work/unpacked"
        changelog="$work/unpacked/usr/share/doc/php$branch-common/changelog.Debian.gz"
        if zgrep -q CVE-2026-109618 "$changelog" && zgrep -q CVE-2026-109619 "$changelog"; then ready=1; fi
      fi
    fi
    if [[ "$ready" == 1 ]]; then printf '%s\n' "$version"; exit 0; fi
    echo "Waiting for patched amd64 PHP $branch package (available: ${version:-none})" >&2
  fi
  if ((SECONDS >= deadline)); then echo "BLOCKED: patched PHP $branch packages are not published yet" >&2; exit 1; fi
  sleep 60
done
