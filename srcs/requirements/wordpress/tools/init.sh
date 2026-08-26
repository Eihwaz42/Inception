#!/bin/bash

# Stop the script immediately if a command fails
set -e

# Create and enter the directory where WordPress files are stored
mkdir -p /var/www/html
cd /var/www/html

# Wait until MariaDB is ready
until mariadb-admin ping -h mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
    sleep 1
done

# Install WordPress only if it has not already been configured
if [ ! -f "/var/www/html/wp-config.php" ]; then

    # Download the WordPress core files
    wp core download --allow-root

    # Create the WordPress configuration and connect it to MariaDB
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="mariadb:3306" \
        --allow-root

    # Install WordPress and create the administrator account
    wp core install \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root

    # Create the second WordPress user with the author role
    wp user create "$WP_USER" "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD" \
        --role=author \
        --allow-root
fi

# Create the directory required by PHP-FPM
mkdir -p /run/php

# Start PHP-FPM in the foreground as the container's main process
exec php-fpm8.2 -F


# WordPress container starts
#          ↓
# Wait for MariaDB
#          ↓
# Is MariaDB ready?
#   NO → sleep 1 → retry
#          ↓
#         YES
#          ↓
# Does wp-config.php exist?
#      ↙              ↘
#     NO              YES
#      ↓                │
# Download WordPress    │
#      ↓                │
# Create wp-config.php  │
#      ↓                │
# Install WordPress     │
# + administrator       │
#      ↓                │
# Create second user    │
#      ↘               ↙
#       Start PHP-FPM
#             ↓
#    Container stays alive