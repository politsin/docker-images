#!/bin/bash

set -e

VERSION="8.3"
BUILD="13"

if docker build . -t synstd/s3-dockup ; then
  docker tag synstd/s3-dockup synstd/s3-dockup:$VERSION
  docker tag synstd/s3-dockup synstd/s3-dockup:$VERSION.$BUILD

  # Push to https://hub.docker.com/r/synstd/s3-dockup
  docker push synstd/s3-dockup:$VERSION.$BUILD
  docker push synstd/s3-dockup:$VERSION
  #docker push synstd/s3-dockup
fi
