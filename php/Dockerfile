ARG PHP="8.3"

FROM synstd/php-service:${PHP}
MAINTAINER Synapse <mail@synapse-studio.ru>

# TODO: ARG NODE="20"
ARG PHP="8.3"
ARG NODE="23"

# Surpress Upstart errors/warning
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl
# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

# APT install:::
RUN apt update -y && \
    apt install -y cron \
                   supervisor \
                   openssh-server && \
    rm -f /etc/cron.d/* && \
    rm -f /etc/cron.daily/* && \
    rm -f /etc/cron.hourly/* && \
    rm -f /etc/cron.monthly/* && \
    rm -f /etc/cron.weekly/* && \
    apt autoremove -y && \
    apt clean && \
    apt autoclean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/man/?? && \
    rm -rf /usr/share/man/??_*

# PhpCS:::
RUN mkdir /var/lib/composer && \
    cd /var/lib/composer && \
    wget https://raw.githubusercontent.com/politsin/snipets/master/patch/composer.json && \
    composer install -o && \
    sed -i 's/snap/var\/lib\/composer\/vendor/g' /etc/environment && \
    /var/lib/composer/vendor/bin/phpcs -i && \
    /var/lib/composer/vendor/bin/phpcs --config-set colors 1 && \
    /var/lib/composer/vendor/bin/phpcs --config-set default_standard Drupal && \
    /var/lib/composer/vendor/bin/phpcs --config-show

# NodeJS:::
RUN curl -SLO https://deb.nodesource.com/nsolid_setup_deb.sh && \
    chmod 500 nsolid_setup_deb.sh && \
    ./nsolid_setup_deb.sh ${NODE} && \
    apt install nodejs -y && \
    node -v && npm -v && \
    npm install -g pnpm && \
    pnpm setup && \
    pnpm -v

# Init:::
RUN pnpm i -g gulp-cli && \
    pnpm i -g webpack-cli

# GulpPacs:::
RUN cd /var && \
    pnpm init --yes && \
    pnpm i gulp && \
    pnpm i node-sass && \
    pnpm i gulp-watch && \
    pnpm i gulp-plumber && \
    pnpm i gulp-touch-cmd && \
    pnpm i gulp-sourcemaps && \
    pnpm i gulp-sass@npm:@selfisekai/gulp-sass && \
    pnpm i webpack webpack-dev-server

# COPY PHP-VER-config:::
COPY config/php/www.conf /etc/php/${PHP}/fpm/pool.d/www.conf
COPY config/php/php.ini /etc/php/${PHP}/fpm/php.ini
COPY config/php/opcache.ini /etc/php/${PHP}/mods-available/opcache.ini
COPY config/php/php-fpm.conf /etc/php/${PHP}/fpm/php-fpm.conf
RUN sed -i "s/-PHP-/${PHP}/g" /etc/php/${PHP}/fpm/php-fpm.conf  && \
    ln -sf /usr/sbin/php-fpm${PHP} /usr/sbin/php-fpm

# COPY script & config:::
COPY config/bash/.bashrc /root/.bashrc
COPY config/bash/.bash_profile /root/.bash_profile
COPY config/cron/www-data /var/spool/cron/crontabs/www-data
COPY config/supervisor/supervisord.conf /etc/supervisord.conf
COPY config/ssmtp/ssmtp.conf /etc/ssmtp/ssmtp.conf
COPY config/start.sh /start.sh


# Fix ownership
RUN chmod 755 /start.sh && \
    mkdir -p /run/sshd && \
    mkdir -p /run/php && \
    chmod -R 0755 /run/php && \
    chown -R www-data:www-data /run/php && \
    chown www-data:www-data /var/spool/cron/crontabs/www-data && \
    chmod 0777 /var/spool/cron/crontabs && \
    chmod 0600 /var/spool/cron/crontabs/www-data && \
    usermod -d /var/www/ www-data && \
    chsh -s /bin/bash www-data

# Permit ssh login with password (auth key only)
RUN sed -i "s/#PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config

# Composer bin to environment
RUN sed -i 's/usr\/local\/games/var\/www\/html\/vendor\/bin/g' /etc/environment

# Expose Ports
EXPOSE 22
EXPOSE 3000

ENTRYPOINT ["/start.sh"]
