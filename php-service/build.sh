#!/bin/bash

set -e

VERSION="8.3"
BUILD="1"

#docker push synstd/php-service
if docker build . -t synstd/php-service ; then
  docker tag synstd/php-service synstd/php-service:$VERSION
  docker tag synstd/php-service synstd/php-service:$VERSION-amd64
  docker tag synstd/php-service synstd/php-service:$VERSION.$BUILD

  # Push to https://hub.docker.com/r/synstd/php-service
  docker push synstd/php-service:$VERSION-amd64
  docker push synstd/php-service:$VERSION.$BUILD
  docker push synstd/php-service:$VERSION
fi
