#!/bin/bash
set -e

IMAGE_NAME="synstd/mattermost"
VERSION="11.5.1"

echo "🚀 Запуск сборки ${IMAGE_NAME}:${VERSION}..."

DOCKER_BUILDKIT=1 docker build \
  --network=host \
  --build-arg MMOST="${VERSION}" \
  --secret id=socks_user,env=SOCKS_USER \
  --secret id=socks_pass,env=SOCKS_PASS \
  --secret id=socks_host,env=SOCKS_HOST \
  --secret id=socks_port,env=SOCKS_PORT \
  -t "${IMAGE_NAME}:${VERSION}" \
  . || { 
    echo "[❌] Ошибка: сборка не удалась"; 
    exit 1; 
  }

echo "📤 Отправка образа на Docker Hub..."
docker push "${IMAGE_NAME}:${VERSION}"

echo "✅ Готово! ${IMAGE_NAME}:${VERSION} опубликован."

# Latest
# docker push "${IMAGE_NAME}"
