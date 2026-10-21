ARG PHP="8.4"

FROM synstd/php-service:${PHP}
MAINTAINER Synapse <mail@synapse-studio.ru>

ARG PHP="8.4"
ARG NODE="26"
# Keep the common Gulp toolchain available to mounted projects that do not
# persist node_modules between container recreations. Local project modules,
# when present, still take precedence over this fallback path.
ENV PNPM_HOME=/usr/local/bin \
    NODE_PATH=/var/node_modules \
    PATH=/var/node_modules/.bin:${PATH}

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
COPY config/phpcs/composer-legacy.json /var/lib/composer/composer-legacy.json
COPY config/phpcs/prepare-standard.php /var/lib/composer/prepare-standard.php
RUN mkdir -p /var/lib/composer && \
    cd /var/lib/composer && \
    case "${PHP}" in \
      7.1) cp composer-legacy.json composer.json ;; \
      *) wget https://raw.githubusercontent.com/politsin/snipets/master/patch/composer.json ;; \
    esac && \
    COMPOSER_IPRESOLVE=4 COMPOSER_MAX_PARALLEL_HTTP=1 composer install --no-progress -o && \
    php /var/lib/composer/prepare-standard.php && \
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
    npm i -g gulp-cli

# GulpPacs::: node-sass is an alias to Dart Sass for legacy gulpfiles.
COPY config/frontend/package*.json /var/
COPY config/frontend/frontend-smoke.sh /usr/local/bin/frontend-smoke.sh
RUN cd /var && npm ci --no-audit --no-fund && \
    for cli in eslint stylelint editorconfig-checker ec; do \
      ln -sf /var/node_modules/.bin/${cli} /usr/local/bin/${cli}; \
    done && \
    eslint --version && stylelint --version && editorconfig-checker --version && \
    npm cache clean --force && chmod 0755 /usr/local/bin/frontend-smoke.sh

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
    mkdir -p /var/log/ssh && \
    touch /var/log/ssh/ssh.log && \
    chmod 0750 /var/log/ssh && \
    chmod 0640 /var/log/ssh/ssh.log && \
    mkdir -p /run/php && \
    chown root:www-data /var/log/ssh /var/log/ssh/ssh.log && \
    chmod -R 0755 /run/php && \
    chown -R www-data:www-data /run/php && \
    chown www-data:www-data /var/spool/cron/crontabs/www-data && \
    chmod 0777 /var/spool/cron/crontabs && \
    chmod 0600 /var/spool/cron/crontabs/www-data && \
    usermod -d /var/www/ www-data && \
    chsh -s /bin/bash www-data

# Permit ssh login with password (auth key only)
RUN sed -i "s/#PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config && \
    printf '\nLogLevel VERBOSE\n' >> /etc/ssh/sshd_config && \
    /usr/sbin/sshd -t

# Composer bin to environment
RUN sed -i 's/usr\/local\/games/var\/www\/html\/vendor\/bin/g' /etc/environment

# Expose Ports
EXPOSE 22
EXPOSE 3000

ENTRYPOINT ["/start.sh"]
