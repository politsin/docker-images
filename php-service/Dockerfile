FROM ubuntu:20.04
MAINTAINER Synapse <mail@synapse-studio.ru>

ARG PHP="8.1"
ARG DIO="0.2.1"

# Surpress Upstart errors/warning
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl
# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

# APT install:::
RUN apt update -y && \
    apt install -y software-properties-common \
                   dnsutils \
                   apt-utils \
                   net-tools \
                   inetutils-ping && \
    apt install -y mc \
                   git \
                   nnn \
                   zip \
                   zsh \
                   curl \
                   htop \
                   nano \
                   ncdu \
                   sass \
                   sudo \
                   wget \
                   putty \
                   unzip \
                   ssmtp \
                   ffmpeg \
                   sshpass \
                   imagemagick &&  \
    apt install -y sqlite3 \
                   redis-tools \
                   mysql-client && \
    apt install -y awscli \
                   python-is-python3 \
                   python3-pip && \
    apt autoremove -y && \
    apt clean && \
    apt autoclean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/man/?? && \
    rm -rf /usr/share/man/??_*

# APT postgresql-15:::
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list && \
    apt update && \
    apt install -y postgresql-client-15 && \
    apt autoremove -y && \
    apt clean && \
    apt autoclean

#  PHP:::
RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php && \
    apt update && \
    apt install -y php${PHP} --no-install-recommends --dry-run && \
	apt purge apache2 apache2-bin && \
    apt install -y php${PHP}-cli \
                   php${PHP}-dev \
                   php${PHP}-dom \
                   php${PHP}-zip \
                   php${PHP}-xml \
                   php${PHP}-curl \
                   php${PHP}-ssh2 \
                   php${PHP}-mysql \
                   php${PHP}-pgsql \
                   php${PHP}-redis \
                   php${PHP}-sqlite3 \
                   php${PHP}-mbstring \
                   php-pear && \
    # Extras:
    apt install -y php${PHP}-gd  \
                   php${PHP}-bz2 \
                   php${PHP}-gmp \
                   php${PHP}-fpm \
                   php${PHP}-apcu \
                   php${PHP}-imap \
                   php${PHP}-intl \
                   php${PHP}-ldap \
                   php${PHP}-soap \
                   php${PHP}-phpdbg \
                   php${PHP}-xmlrpc \
                   php${PHP}-xdebug \
                   php${PHP}-bcmath \
                   php${PHP}-imagick \
                   php${PHP}-memcached && \
    apt autoremove -y && \
    apt clean && \
    apt autoclean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/man/?? && \
    rm -rf /usr/share/man/??_*

# Disable php-xdebug:::
RUN echo '' > /etc/php/${PHP}/mods-available/xdebug.ini

# Redis:::
RUN pecl channel-update pecl.php.net
RUN pecl install -f -o redis

# gRPC:::
RUN pecl install grpc && \
    echo 'extension=grpc.so' > /etc/php/${PHP}/mods-available/grpc.ini && \
    ln -s /etc/php/${PHP}/mods-available/grpc.ini /etc/php/${PHP}/fpm/conf.d/20-grpc.ini && \
    ln -s /etc/php/${PHP}/mods-available/grpc.ini /etc/php/${PHP}/cli/conf.d/20-grpc.ini

# Uploadprogress:::
RUN pecl install uploadprogress && \
    echo 'extension=uploadprogress.so' > /etc/php/${PHP}/mods-available/uploadprogress.ini && \
    ln -s /etc/php/{PHP}/mods-available/uploadprogress.ini /etc/php/${PHP}/fpm/conf.d/20-uploadprogress.ini

# DIO `pecl install dio` # OR
RUN pecl install channel://pecl.php.net/dio-${DIO} && \
    echo 'extension=dio.so' > /etc/php/${PHP}/mods-available/dio.ini && \
    ln -s /etc/php/${PHP}/mods-available/dio.ini /etc/php/${PHP}/cli/conf.d/20-dio.ini

# Composer:::
RUN wget https://getcomposer.org/installer -q -O composer-setup.php && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    chmod +x /usr/local/bin/composer


# COPY script & config:::
RUN php --ini
COPY service /opt/app/php/service
RUN composer install -d /opt/app/php/service
RUN ls /opt/app/php/service
#Fix ownership
RUN chmod 755 /opt/app/php/service/run.php

# Expose Ports
EXPOSE 80

ENTRYPOINT ["/usr/bin/php", "/opt/app/php/service/run.php"]
