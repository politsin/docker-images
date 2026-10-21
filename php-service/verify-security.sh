#!/bin/sh
set -eu
branch="$1"
actual=$(php -r 'echo PHP_VERSION;')
case "$actual" in "$branch".*) ;; *) echo "Wrong PHP branch: $actual, expected $branch" >&2; exit 1 ;; esac
"php-fpm${branch}" -v | grep -F "PHP $actual " >/dev/null || {
  echo 'CLI and FPM PHP versions differ' >&2; exit 1;
}
minimum=""
case "$branch" in
  8.5) minimum=8.5.12 ;; 8.4) minimum=8.4.27 ;;
  8.3) minimum=8.3.36 ;; 8.2) minimum=8.2.35 ;;
esac
if [ -n "$minimum" ]; then
  dpkg --compare-versions "$actual" ge "$minimum" || {
    echo "BLOCKED: PHP $actual predates critical security release $minimum" >&2; exit 1;
  }
else
  for cve in CVE-2026-109618 CVE-2026-109619; do
    zcat "/usr/share/doc/php${branch}-common/changelog.Debian.gz" | grep -F "$cve" || {
      echo "BLOCKED: no vendor backport evidence for $cve, PHP $branch" >&2; exit 1;
    }
  done
fi
echo "PHP_SECURITY_OK $actual"
