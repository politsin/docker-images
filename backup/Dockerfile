ARG PHP="8.1"

FROM synstd/php-service:${PHP}
MAINTAINER Synapse <mail@synapse-studio.ru>

#COPY script & config:::
COPY console /opt/console
RUN composer install -d /opt/console
RUN ls /opt/console/vendor

#Fix ownership
RUN chmod 755 /opt/console/console.php

ENTRYPOINT ["/usr/bin/php", "/opt/console/console.php"]
