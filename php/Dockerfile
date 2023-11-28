ARG PHP="8.1"

FROM synstd/php-service:${PHP}
MAINTAINER Synapse <mail@synapse-studio.ru>

# TODO: ARG NODE="20"
ARG PHP="8.1"
ARG NODE="20"

# Surpress Upstart errors/warning
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl
# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

# APT install:::
RUN apt update -y && \
    apt install -y cron \
                   supervisor \
                   openssh-server &&  \
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

#NodeJS:::
RUN curl -SLO https://deb.nodesource.com/nsolid_setup_deb.sh && \
    chmod 500 nsolid_setup_deb.sh && \
    ./nsolid_setup_deb.sh ${NODE} && \
    apt-get install nodejs -y && \
    node -v && npm -v && \
    npm install -g npm && \
    npm -v


#Init:::
RUN npm i -g yarn && \
    npm i -g gulp-cli && \
    npm i -g webpack-cli

#GulpPacs:::
RUN cd /var && \
    npm init --yes && \
    npm i gulp && \
    npm i node-sass && \
    npm i gulp-watch && \
    npm i gulp-plumber && \
    npm i gulp-touch-cmd && \
    npm i gulp-sourcemaps && \
    npm i gulp-sass@npm:@selfisekai/gulp-sass && \
    npm i webpack webpack-dev-server


# COPY PHP-VER-config:::
COPY config/php${PHP}/php/php-fpm.conf /etc/php/${PHP}/fpm/php-fpm.conf
COPY config/php${PHP}/supervisor/supervisord.conf /etc/supervisord.conf

# COPY script & config:::
COPY config/bash/.bashrc /root/.bashrc
COPY config/bash/.bash_profile /root/.bash_profile
COPY config/cron/www-data /var/spool/cron/crontabs/www-data
COPY config/php/php.ini /etc/php/${PHP}/fpm/php.ini
COPY config/php/www.conf /etc/php/${PHP}/fpm/pool.d/www.conf
COPY config/php/opcache.ini /etc/php/${PHP}/mods-available/opcache.ini
COPY config/ssmtp/ssmtp.conf /etc/ssmtp/ssmtp.conf
COPY config/start.sh /start.sh

# Fix ownership
RUN chmod 755 /start.sh && \
    mkdir /run/sshd && \
    mkdir /run/php && \
    chown -R www-data.www-data /run/php && \
    chown www-data.www-data /var/spool/cron/crontabs/www-data && \
    chmod 0777 /var/spool/cron/crontabs && \
    chmod 0600 /var/spool/cron/crontabs/www-data

# Permit ssh login with password (auth key only)
RUN sed -i "s/#PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config

# Expose Ports
EXPOSE 22

ENTRYPOINT ["/start.sh"]
