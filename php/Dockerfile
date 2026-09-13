ARG PHP="8.4"

FROM synstd/php-service:${PHP}
MAINTAINER Synapse <mail@synapse-studio.ru>

ARG PHP="8.4"
ARG NODE="26"
ENV PNPM_HOME=/usr/local/bin

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
COPY config/phpcs/no-drupal-commenting.xml /var/lib/composer/phpcs.xml
RUN mkdir -p /var/lib/composer && \
    cd /var/lib/composer && \
    wget https://raw.githubusercontent.com/politsin/snipets/master/patch/composer.json && \
    COMPOSER_IPRESOLVE=4 COMPOSER_MAX_PARALLEL_HTTP=1 composer install --no-progress -o && \
    sed -i 's/snap/var\/lib\/composer\/vendor/g' /etc/environment && \
    /var/lib/composer/vendor/bin/phpcs -i && \
    /var/lib/composer/vendor/bin/phpcs --config-set colors 1 && \
    /var/lib/composer/vendor/bin/phpcs --config-set default_standard /var/lib/composer/phpcs.xml && \
    /var/lib/composer/vendor/bin/phpcs --config-show

# NodeJS:::
RUN curl -SLO https://deb.nodesource.com/nsolid_setup_deb.sh && \
    chmod 500 nsolid_setup_deb.sh && \
    ./nsolid_setup_deb.sh ${NODE} && \
    apt update && \
    apt install nodejs -y && \
    node -v && npm -v && \
    rm -rf /var/lib/apt/lists/*

# Init:::
RUN npm config set fetch-retries 5 && \
    npm config set fetch-retry-mintimeout 20000 && \
    npm config set fetch-retry-maxtimeout 120000 && \
    npm i -g pnpm && \
    pnpm config set dangerouslyAllowAllBuilds true && \
    npm i -g gulp-cli

# GulpPacs:::
RUN cd /var && \
    pnpm init && \
    pnpm i gulp && \
    pnpm i sass && \
    pnpm i gulp-watch && \
    pnpm i gulp-plumber && \
    pnpm i gulp-touch-cmd && \
    pnpm i gulp-sourcemaps && \
    pnpm i gulp-sass@npm:@selfisekai/gulp-sass && \
    npm uninstall -g pnpm && \
    rm -rf /usr/local/bin/store /root/.cache /root/.local/share/pnpm

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
COPY config/cron/filter-ssh-log /usr/local/sbin/filter-ssh-log
COPY config/cron/ssh-log-filter /etc/cron.d/ssh-log-filter
COPY config/ssmtp/ssmtp.conf /etc/ssmtp/ssmtp.conf
COPY config/start.sh /start.sh


# Fix ownership
RUN chmod 755 /start.sh && \
    chmod 0755 /usr/local/sbin/filter-ssh-log && \
    chmod 0644 /etc/cron.d/ssh-log-filter && \
    mkdir -p /run/sshd && \
    touch /var/log/ssh.log && \
    chmod 0640 /var/log/ssh.log && \
    mkdir -p /run/php && \
    chown root:www-data /var/log/ssh.log && \
    chmod -R 0755 /run/php && \
    chown -R www-data:www-data /run/php && \
    chown www-data:www-data /var/spool/cron/crontabs/www-data && \
    chmod 0777 /var/spool/cron/crontabs && \
    chmod 0600 /var/spool/cron/crontabs/www-data && \
    usermod -d /var/www/ www-data && \
    chsh -s /bin/bash www-data

# Permit ssh login with password (auth key only)
RUN sed -i "s/#PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config && \
    printf '\\nLogLevel VERBOSE\\n' >> /etc/ssh/sshd_config

# Composer bin to environment
RUN sed -i 's/usr\/local\/games/var\/www\/html\/vendor\/bin/g' /etc/environment

# Expose Ports
EXPOSE 22
EXPOSE 3000

ENTRYPOINT ["/start.sh"]
