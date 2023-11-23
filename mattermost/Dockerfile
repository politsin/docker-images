FROM alpine:edge

#Install:::
RUN wget https://releases.mattermost.com/9.2.2/mattermost-9.2.2-linux-amd64.tar.gz && \
    tar -xvzf mattermost*.gz && \
    mv mattermost /opt && \
    rm mattermost*.gz && \
    mkdir /opt/mattermost/data

# Expose Ports
EXPOSE 8065

ENTRYPOINT ["/opt/mattermost/bin/mattermost"]
