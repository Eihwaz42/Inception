#!/bin/bash

set -e

# dossier où les fichiers WordPress vivront dans le conteneur
mkdir -p /var/www/html
cd /var/www/html

# attend que MariaDB soit prêt
until mariadb-admin ping -h mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
    sleep 1
done

# installe WordPress uniquement s'il n'est pas déjà configuré
if [ ! -f "/var/www/html/wp-config.php" ]; then
    wp core download --allow-root

    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="mariadb:3306" \
        --allow-root
    
    wp core install \
        --url="$WP_URL" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root

    wp user create "$WP_USER" "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD" \
        --role=author \
        --allow-root
fi

mkdir -p /run/php

exec php-fpm8.2 -F

# container WordPress démarre
#        ↓
# attend MariaDB
#        ↓
# MariaDB répond ?
#   NON → sleep 1 → réessaie
#        ↓
#       OUI
#        ↓
# wp-config.php existe ?
#   NON → télécharge WordPress
#         ↓
#         crée wp-config.php
#         ↓
#         installe le site + admin
#         ↓
#         crée le 2e utilisateur
#   OUI → ne réinstalle pas
#        ↓
# lance PHP-FPM au premier plan
#        ↓
# container reste vivant