ARG PHP="8.1"
FROM synstd/php-service:${PHP}
ARG PHP="8.1"


MAINTAINER Synapse <mail@synapse-studio.ru>

#COPY script & config:::
COPY config/opcache.ini /etc/php/${PHP}/mods-available/opcache.ini
COPY console /opt/console
RUN composer install -d /opt/console
RUN ls /opt/console/vendor

#Fix ownership
RUN chmod 755 /opt/console/console.php
RUN sudo -u www-data mkdir /var/www/opcache

ENTRYPOINT ["/usr/bin/php", "/opt/console/console.php"]
