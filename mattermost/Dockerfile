FROM ubuntu:24.04

ARG MMOST="11.5.1"

RUN --mount=type=secret,id=socks_user \
    --mount=type=secret,id=socks_pass \
    --mount=type=secret,id=socks_host \
    --mount=type=secret,id=socks_port \
    \
    SOCKS_USER="$(cat /run/secrets/socks_user)" && \
    SOCKS_PASS="$(cat /run/secrets/socks_pass)" && \
    SOCKS_HOST="$(cat /run/secrets/socks_host)" && \
    SOCKS_PORT="$(cat /run/secrets/socks_port)" && \
    \
    # Собираем строку прокси
    PROXY_URL="socks5h://${SOCKS_USER}:${SOCKS_PASS}@${SOCKS_HOST}:${SOCKS_PORT}" && \
    \
    # Установка зависимостей
    apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates tar && \
    \
    # Скачивание через прокси
    curl -fSL -x "$PROXY_URL" \
        "https://releases.mattermost.com/${MMOST}/mattermost-${MMOST}-linux-amd64.tar.gz" \
        -o /tmp/mattermost.tar.gz && \
    \
    # Распаковка
    mkdir -p /opt/mattermost && \
    tar -xzf /tmp/mattermost.tar.gz -C /opt/mattermost --strip-components=1 && \
    \
    # Очистка
    rm -f /tmp/mattermost.tar.gz && \
    apt-get purge -y curl && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/mattermost
EXPOSE 8065
CMD ["./bin/mattermost"]