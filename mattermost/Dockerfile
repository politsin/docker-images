FROM ubuntu:20.04

ARG MMOST="9.2.2"

# WGET! APT install:::
RUN apt update -y && \
    apt install -y wget \
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
RUN wget https://releases.mattermost.com/${MMOST}/mattermost-${MMOST}-linux-amd64.tar.gz && \
    tar -xvzf mattermost*.gz && \
    mv mattermost /opt && \
    rm mattermost*.gz && \
    mkdir /opt/mattermost/data && \
    chmod +x /opt/mattermost/bin/mattermost

# Expose Ports
EXPOSE 8065

ENTRYPOINT ["/opt/mattermost/bin/mattermost"]
