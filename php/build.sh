#!/bin/bash

VERSION="8.1"
BUILD="251"

# cd /opt/build/docker-php
if docker build . -t synstd/php ; then
  docker tag synstd/php synstd/php:$VERSION
  docker tag synstd/php synstd/php:$VERSION-amd64
  docker tag synstd/php synstd/php:$VERSION.$BUILD

  # Push to https://hub.docker.com/r/synstd/php
  docker push synstd/php:$VERSION-amd64
  docker push synstd/php:$VERSION.$BUILD
  docker push synstd/php:$VERSION
fi
