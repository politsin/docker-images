#!/bin/bash

# docker login --username=synstd
# тут нужно ввести пароль

docker build --network=host -t synstd/mattermost . || { 
    echo "[!] Ошибка: сборка не удалась"; 
    exit 1; 
}
docker tag synstd/mattermost synstd/mattermost:10.11.2
docker push synstd/mattermost
docker push synstd/mattermost:10.11.2