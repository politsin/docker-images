#!/bin/bash

VERSION="8.1"
BUILD="0"

# cd /opt/build/docker-php
docker build . -t synstd/php-service
docker tag synstd/php-service synstd/php-service:$VERSION
docker tag synstd/php-service synstd/php-service:$VERSION.$BUILD
docker push synstd/php-service
docker push synstd/php-service:$VERSION
docker push synstd/php-service:$VERSION.$BUILD
