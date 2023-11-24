#!/bin/bash

VERSION="8.2"
BUILD="0"

#docker push synstd/php-service
docker build . -t synstd/php-service
docker tag synstd/php-service synstd/php-service:$VERSION
docker tag synstd/php-service synstd/php-service:$VERSION.$BUILD
docker push synstd/php-service:$VERSION
docker push synstd/php-service:$VERSION.$BUILD
