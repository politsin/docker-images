#!/bin/bash
cd /opt/build/exim
docker build -t synstd/exim .
docker tag synstd/exim synstd/exim:4.97
# docker login --username=synstd
# тут нужно ввести пароль

docker push synstd/exim
docker push synstd/exim:4.97
