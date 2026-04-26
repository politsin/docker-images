#!/bin/bash

set -euo pipefail

VERSION="${VERSION:-8.3}"

docker manifest create synstd/php-service:$VERSION \
--amend synstd/php-service:$VERSION-amd64 \
--amend synstd/php-service:$VERSION-arm

docker manifest push synstd/php-service:$VERSION
