FROM ubuntu:26.04
MAINTAINER Synapse <mail@synapse-studio.ru>

ARG PHP="8.4"
ARG DIO="0.3.0"
ARG TARGETARCH="amd64"
ARG WKHTMLTOX_VERSION="0.12.6.1-3"
ARG YQ_VERSION="4.47.2"

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
                   imagemagick \
                   fontconfig \
                   libxrender1 \
                   libxext6 \
                   xfonts-75dpi \
                   xfonts-base &&  \
    apt install -y sqlite3 \
                   redis-tools \
                   mysql-client && \
    apt install -y python-is-python3 \
                   python3-pip && \
    # CLI tools commonly used by coding/ops AI agents.
    apt install -y jq \
                   ripgrep \
                   fd-find \
                   tree \
                   file \
                   less \
                   lsof \
                   strace \
                   iproute2 \
                   netcat-openbsd \
                   socat \
                   rsync \
                   pv \
                   gettext-base \
                   dos2unix \
                   bc \
                   inotify-tools \
                   shellcheck && \
    ln -sf /usr/bin/fdfind /usr/local/bin/fd && \
    apt autoremove -y && \
    apt clean && \
    apt autoclean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/man/?? && \
    rm -rf /usr/share/man/??_*

# wkhtmltopdf with patched Qt is installed from the upstream packaging release.
RUN set -eux; \
    case "$TARGETARCH" in \
      amd64|arm64) wkhtmltox_arch="${TARGETARCH}" ;; \
      *) echo "Unsupported TARGETARCH for wkhtmltox: $TARGETARCH" >&2; exit 1 ;; \
    esac; \
    wget -O /tmp/wkhtmltox.deb "https://github.com/wkhtmltopdf/packaging/releases/download/${WKHTMLTOX_VERSION}/wkhtmltox_${WKHTMLTOX_VERSION}.jammy_${wkhtmltox_arch}.deb" && \
    mkdir -p /tmp/wkhtmltox-repack && \
    dpkg-deb -R /tmp/wkhtmltox.deb /tmp/wkhtmltox-repack && \
    sed -i 's/libssl3/libssl3t64 | libssl3/g' /tmp/wkhtmltox-repack/DEBIAN/control && \
    dpkg-deb -b /tmp/wkhtmltox-repack /tmp/wkhtmltox-fixed.deb && \
    apt update -y && \
    apt install -y /tmp/wkhtmltox-fixed.deb && \
    rm -rf /tmp/wkhtmltox.deb /tmp/wkhtmltox-fixed.deb /tmp/wkhtmltox-repack && \
    wkhtmltopdf --version && \
    wkhtmltopdf about:blank /tmp/wkhtmltopdf-smoke.pdf && \
    test -s /tmp/wkhtmltopdf-smoke.pdf && \
    rm -f /tmp/wkhtmltopdf-smoke.pdf && \
    apt clean && \
    apt autoclean && \
    rm -rf /var/lib/apt/lists/*

# yq (Mike Farah implementation expected by most AI/code agents)
RUN set -eux; \
    case "$TARGETARCH" in \
      amd64|arm64) yq_arch="${TARGETARCH}" ;; \
      *) echo "Unsupported TARGETARCH for yq: $TARGETARCH" >&2; exit 1 ;; \
    esac; \
    wget -qO /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_${yq_arch}" && \
    chmod 0755 /usr/local/bin/yq && \
    yq --version

# Aws - cli
RUN set -eux; \
    case "$TARGETARCH" in \
      amd64) aws_arch="x86_64" ;; \
      arm64) aws_arch="aarch64" ;; \
      *) echo "Unsupported TARGETARCH: $TARGETARCH" >&2; exit 1 ;; \
    esac; \
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${aws_arch}.zip" -o awscliv2.zip && \
    unzip -q awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws && \
    /usr/local/bin/aws --version

# APT postgresql client:::
RUN apt update && \
    apt install -y postgresql-client && \
    apt autoremove -y && \
    apt clean && \
    apt autoclean

#  PHP:::
# Ondrej PPA does not publish Ubuntu 26.04 packages yet. Keep the OS base on
# 26.04 and use noble only for the PHP repo plus missing PHP ABI dependencies.
RUN find /etc/apt -type f \( -name '*.sources' -o -name '*.list' \) -exec sed -i -e 's|http://archive.ubuntu.com/ubuntu|http://mirror.yandex.ru/ubuntu|g' -e 's|http://security.ubuntu.com/ubuntu|http://mirror.yandex.ru/ubuntu|g' {} + && \
    LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php || true && \
    find /etc/apt/sources.list.d -type f -name '*ondrej*php*.sources' -exec sed -i 's/^Suites: .*/Suites: noble/' {} + && \
    find /etc/apt/sources.list.d -type f -name '*ondrej*php*.list' -exec sed -i 's/[[:space:]]resolute[[:space:]]/[[:space:]]noble[[:space:]]/g' {} + && \
    printf '%s\n' \
      'Types: deb' \
      'URIs: http://mirror.yandex.ru/ubuntu/' \
      'Suites: noble noble-updates noble-security' \
      'Components: main universe' \
      'Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg' \
      > /etc/apt/sources.list.d/ubuntu-noble.sources && \
    apt update && \
    apt install -y php${PHP} --no-install-recommends --dry-run && \
	apt purge apache2 apache2-bin && \
    apt install -y --no-install-recommends php${PHP}-cli \
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
    apt install -y --no-install-recommends php${PHP}-gd  \
                   php${PHP}-bz2 \
                   php${PHP}-gmp \
                   php${PHP}-fpm \
                   php${PHP}-apcu \
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

# Redis::: php${PHP}-redis \
# RUN pecl channel-update pecl.php.net
# RUN pecl install -f -o redis

# gRPC:::
# For PHP 8.5 use PECL build to avoid ABI mismatch seen in distro php8.5-grpc.
RUN set -eux; \
    case "${PHP}" in \
      8.5) \
        apt update; \
        apt install -y build-essential binutils pkg-config zlib1g-dev; \
        curl -fsSL https://github.com/php/pie/releases/latest/download/pie.phar -o /usr/local/bin/pie; \
        chmod 0755 /usr/local/bin/pie; \
        pie install grpc/grpc-php-ext; \
        strip --strip-unneeded "$(/usr/bin/php-config${PHP} --extension-dir)/grpc.so"; \
        test -s "$(/usr/bin/php-config${PHP} --extension-dir)/grpc.so"; \
        for sapi in cli fpm phpdbg; do rm -f "/etc/php/${PHP}/${sapi}/conf.d/80-grpc.ini"; done; \
        apt purge -y build-essential binutils pkg-config zlib1g-dev; \
        apt autoremove -y; \
        rm -rf /tmp/pear /tmp/pear-*; \
        echo 'extension=grpc.so' > /etc/php/${PHP}/mods-available/grpc.ini; \
        ln -sf /etc/php/${PHP}/mods-available/grpc.ini /etc/php/${PHP}/cli/conf.d/20-grpc.ini; \
        ln -sf /etc/php/${PHP}/mods-available/grpc.ini /etc/php/${PHP}/fpm/conf.d/20-grpc.ini; \
        ;; \
      *) \
        apt update; \
        apt install -y php${PHP}-grpc; \
        ;; \
    esac; \
    php -m | grep -i '^grpc$'; \
    php --ri grpc >/dev/null; \
    apt clean; \
    apt autoclean; \
    rm -rf /var/lib/apt/lists/*

# Uploadprogress:::
RUN apt update && \
    apt install -y build-essential pkg-config zlib1g-dev && \
    git clone --depth 1 https://github.com/php/pecl-php-uploadprogress /tmp/uploadprogress && \
    cd /tmp/uploadprogress && \
    phpize && \
    ./configure --enable-uploadprogress && \
    make -j"$(nproc)" && \
    make install && \
    cd / && \
    rm -rf /tmp/uploadprogress && \
    echo 'extension=uploadprogress.so' > /etc/php/${PHP}/mods-available/uploadprogress.ini && \
    ln -s /etc/php/${PHP}/mods-available/uploadprogress.ini /etc/php/${PHP}/fpm/conf.d/20-uploadprogress.ini && \
    ln -s /etc/php/${PHP}/mods-available/uploadprogress.ini /etc/php/${PHP}/cli/conf.d/20-uploadprogress.ini && \
    rm -rf /tmp/pear /tmp/pear-* && \
    apt purge -y build-essential pkg-config zlib1g-dev && \
    apt autoremove -y && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# DIO `pecl install dio` # OR
RUN set -eux; \
    case "${PHP}" in \
      7.2|7.4) echo "Skip dio for PHP ${PHP}; previous images did not include it and current dio requires PHP >= 8.0" ;; \
      *) \
        apt update; \
        apt install -y build-essential pkg-config zlib1g-dev; \
        test -x /usr/local/bin/pie || curl -fsSL https://github.com/php/pie/releases/latest/download/pie.phar -o /usr/local/bin/pie; \
        chmod 0755 /usr/local/bin/pie; \
        pie install pecl/dio; \
        echo 'extension=dio.so' > /etc/php/${PHP}/mods-available/dio.ini; \
        for sapi in cli fpm phpdbg; do \
          test -d "/etc/php/${PHP}/${sapi}/conf.d" || continue; \
          rm -f "/etc/php/${PHP}/${sapi}/conf.d/80-dio.ini"; \
          ln -sf /etc/php/${PHP}/mods-available/dio.ini "/etc/php/${PHP}/${sapi}/conf.d/20-dio.ini"; \
        done; \
        apt purge -y build-essential pkg-config zlib1g-dev; \
        apt autoremove -y; \
        apt clean; \
        rm -rf /var/lib/apt/lists/*; \
        ;; \
    esac

# Build-only PHP extension tooling is not needed at runtime.
RUN set -eux; \
    packages=""; \
    for package in php${PHP}-dev php-pear build-essential gcc g++ cpp pkg-config zlib1g-dev; do \
      dpkg-query -W -f='${Status}' "${package}" 2>/dev/null | grep -qx 'install ok installed' && packages="${packages} ${package}" || true; \
    done; \
    test -z "${packages}" || apt purge -y ${packages}; \
    apt autoremove -y; \
    apt clean; \
    rm -rf /var/lib/apt/lists/* /tmp/pear /tmp/pear-* /usr/local/bin/pie

# Composer:::
RUN wget https://getcomposer.org/installer -q -O composer-setup.php && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    chmod +x /usr/local/bin/composer


# COPY script & config:::
RUN php --ini
COPY service /opt/app/php/service
RUN case "${PHP}" in \
      7.2|7.4|8.0) echo "Skip service composer install for PHP ${PHP}; service composer.json requires PHP ^8.1 and run.php has no vendor dependency" ;; \
      *) composer install -d /opt/app/php/service ;; \
    esac
RUN ls /opt/app/php/service
#Fix ownership
RUN chmod 755 /opt/app/php/service/run.php

# Expose Ports
EXPOSE 80

ENTRYPOINT ["/usr/bin/php", "/opt/app/php/service/run.php"]
