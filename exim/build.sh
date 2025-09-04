#!/bin/bash
set -e

docker build -t synstd/exim .
docker tag synstd/exim synstd/exim:4.98.2
# docker login --username=synstd
# тут нужно ввести пароль

docker push synstd/exim
docker push synstd/exim:4.98.2
