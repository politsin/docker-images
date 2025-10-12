#!/bin/bash

set -e

VERSION="8.4"
BUILD="3"

if docker build . -t synstd/php ; then
  docker tag synstd/php synstd/php:$VERSION
  docker tag synstd/php synstd/php:$VERSION-amd64
  docker tag synstd/php synstd/php:$VERSION.$BUILD

  # Push to https://hub.docker.com/r/synstd/php
  docker push synstd/php:$VERSION-amd64
  docker push synstd/php:$VERSION.$BUILD
  docker push synstd/php:$VERSION
fi
