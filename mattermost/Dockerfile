FROM synstd/php:8.1.250
MAINTAINER Synapse <mail@synapse-studio.ru>

#APT-GET:::
RUN wget https://releases.mattermost.com/9.1.1/mattermost-9.1.1-linux-amd64.tar.gz && \
    tar -xvzf mattermost*.gz && \
    mv mattermost /opt && \
    rm mattermost*.gz && \
    mkdir /opt/mattermost/data

#COPY script & config:::
COPY config/supervisor/supervisord.conf /etc/supervisord.conf
COPY config/start.sh /start.sh

#Fix ownership
RUN chmod 755 /start.sh && \
    chown www-data.www-data /var/spool/cron/crontabs/www-data && \
    chmod 0777 /var/spool/cron/crontabs && \
    chmod 0600 /var/spool/cron/crontabs/www-data

# Expose Ports
EXPOSE 22
EXPOSE 8065

ENTRYPOINT ["/start.sh"]
