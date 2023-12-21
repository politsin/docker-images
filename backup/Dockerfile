ARG PHP="8.1"
FROM synstd/php-service:${PHP}
ARG PHP="8.1"


MAINTAINER Synapse <mail@synapse-studio.ru>

#COPY script & config:::
COPY config/opcache.ini /etc/php/${PHP}/mods-available/opcache.ini
COPY console /opt/console
RUN mkdir /var/www && \
  chown www-data:www-data /var/www && \
  sudo -u www-data mkdir /var/www/opcache && \
  composer install -d /opt/console && \
  ls /opt/console/vendor && \
  chmod 755 /opt/console/console.php

ENTRYPOINT ["/usr/bin/php", "/opt/console/console.php"]
