#!/bin/bash

# docker login --username=synstd
# тут нужно ввести пароль

docker build -t synstd/mattermost .
docker tag synstd/mattermost synstd/mattermost:10.9.2
docker push synstd/mattermost
docker push synstd/mattermost:10.9.2
