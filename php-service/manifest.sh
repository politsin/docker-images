#!/bin/bash

VERSION="8.2"

docker manifest create synstd/php-service:$VERSION \
--amend synstd/php-service:$VERSION-amd64 \
--amend synstd/php-service:$VERSION-arm

docker manifest push synstd/php-service:$VERSION