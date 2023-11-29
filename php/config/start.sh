#!/bin/bash

# echo "Europe/Moscow" > /etc/timezone
# cp /usr/share/zoneinfo/Europe/Moscow /etc/localtime

# www-data user
FILE=/var/www/chown
if [ -e "$FILE" ]; then
  chown -Rf www-data:www-data /var/www/.ssh
  chmod 600 /var/www/.ssh/authorized_keys
  echo "File $FILE exists."
else
  chown www-data:www-data /var/www/
  chown www-data:www-data /var/www/html
  chown www-data:www-data /var/www/opcache
  chown www-data:www-data /var/www/.bash_profile
  chown www-data:www-data /var/www/.bashrc
  chown www-data:www-data /var/www/.gitconfig
  chown -Rf www-data:www-data /var/www/.drush

  # ssh
  chown -Rf www-data:www-data /var/www/.ssh
  chmod 600 /var/www/.ssh/authorized_keys

  # cron
  chown www-data:www-data /var/spool/cron/crontabs/www-data
  chmod 0777 /var/spool/cron/crontabs
  chmod 0600 /var/spool/cron/crontabs/www-data

  # Sockets
  chmod -R 0777 /run/php
  chmod -R 0777 /run/mysqld

  # Done
  echo "done" > $FILE
  chown -R www-data:www-data $FILE
fi

# Start supervisord and services
/usr/bin/supervisord -n -c /etc/supervisord.conf
