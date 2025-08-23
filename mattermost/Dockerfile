FROM ubuntu:24.04

ARG MMOST="10.11.2"

ARG SOCKS_USER=
ARG SOCKS_PASS=
ARG SOCKS_HOST=
ARG SOCKS_PORT=

# WGET! APT install:::
RUN apt update -y && \
    apt install -y wget \
	               curl \
                   dnsutils \
                   net-tools \
                   inetutils-ping && \
    apt autoremove -y && \
    apt clean && \
    apt autoclean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/man/?? && \
    rm -rf /usr/share/man/??_*

#Install:::
RUN set -eux; \
    URL="https://releases.mattermost.com/${MMOST}/mattermost-${MMOST}-linux-amd64.tar.gz"; \
    curl -fL \
      --socks5-hostname ${SOCKS_USER}:${SOCKS_PASS}@${SOCKS_HOST}:${SOCKS_PORT} \
      -o /tmp/mattermost.tar.gz "$URL"; \
    tar -xzf /tmp/mattermost.tar.gz -C /opt; \
    rm /tmp/mattermost.tar.gz; \
    mkdir -p /opt/mattermost/data; \
    chmod +x /opt/mattermost/bin/mattermost

# Проверить версию во время билда (даст понятный лог и оборвёт билд при проблеме)
RUN /opt/mattermost/bin/mattermost version || (echo "Mattermost not installed" >&2; exit 1)

# Expose Ports
EXPOSE 8065

ENTRYPOINT ["/opt/mattermost/bin/mattermost"]
