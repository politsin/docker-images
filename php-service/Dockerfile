FROM ubuntu:20.04
MAINTAINER Synapse <mail@synapse-studio.ru>

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

#APT postgresql-15:::
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list && \
    apt update && \
    apt install -y postgresql-client-15 && \
    apt autoremove -y && \
    apt clean && \
    apt autoclean

#PHP:::
RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php && \
    apt update && \
    apt install -y php8.2 \
                   php8.2-cli \
                   php8.2-dev \
                   php8.2-dom \
                   php8.2-zip \
                   php8.2-xml \
                   php8.2-curl \
                   php8.2-mysql \
                   php8.2-pgsql \
                   php8.2-mbstring \
                   php-xml \
                   php-json \
                   php-pear \
                   php-ssh2 \
                   php-redis \
                   php-sqlite3 && \
    # Extras:
    apt install -y php8.2-gd  \
                   php8.2-bz2 \
                   php8.2-cgi \
                   php8.2-gmp \
                   php8.2-fpm \
                   php8.2-apcu \
                   php8.2-soap \
                   php8.2-imap \
                   php8.2-intl \
                   php8.2-ldap \
                   php8.2-phpdbg \
                   php8.2-xmlrpc \
                   php8.2-xdebug \
                   php8.2-bcmath \
                   php8.2-imagick \
                   php8.2-opcache \
                   php8.2-memcached && \
    apt autoremove -y && \
    apt clean && \
    apt autoclean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/man/?? && \
    rm -rf /usr/share/man/??_*

# Disable php-xdebug:::
RUN echo '' > /etc/php/8.2/mods-available/xdebug.ini

#Redis:::
RUN pecl channel-update pecl.php.net
RUN pecl install -f -o redis

#gRPC:::
RUN pecl install grpc && \
    echo 'extension=grpc.so' > /etc/php/8.2/mods-available/grpc.ini && \
    ln -s /etc/php/8.2/mods-available/grpc.ini /etc/php/8.2/fpm/conf.d/20-grpc.ini && \
    ln -s /etc/php/8.2/mods-available/grpc.ini /etc/php/8.2/cli/conf.d/20-grpc.ini

#DIO `pecl install dio` # OR
RUN pecl install channel://pecl.php.net/dio-0.2.1 && \
    echo 'extension=dio.so' > /etc/php/8.2/mods-available/dio.ini && \
    ln -s /etc/php/8.2/mods-available/dio.ini /etc/php/8.2/cli/conf.d/20-dio.ini

#DRUSH:::
RUN wget https://github.com/drush-ops/drush-launcher/releases/latest/download/drush.phar -q -O drush && \
    chmod +x drush && \
    mv drush /usr/local/bin/drush

#Composer:::
RUN wget https://getcomposer.org/installer -q -O composer-setup.php && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    chmod +x /usr/local/bin/composer


#COPY script & config:::
RUN php --ini
COPY service /opt/app/php/service
RUN composer install -d /opt/app/php/service
RUN ls /opt/app/php/service
#Fix ownership
RUN chmod 755 /opt/app/php/service/run.php

# Expose Ports
EXPOSE 80

ENTRYPOINT ["/usr/bin/php", "/opt/app/php/service/run.php"]
