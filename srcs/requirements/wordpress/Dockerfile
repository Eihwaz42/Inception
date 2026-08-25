FROM debian:bookworm

# php-fpm : exécute le PHP de WordPress
# php-mysql : permet à PHP de parler à MariaDB/MySQL
# mariadb-client : outils client pour tester/parler à MariaDB
# curl : pour télécharger WordPress / WP-CLI
RUN apt-get update \
    && apt-get install -y \
        php-fpm \
        php-mysql \
        mariadb-client \
        curl \
    && rm -rf /var/lib/apt/lists/*

# outil officiel de configuration WordPress
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/init.sh /usr/local/bin/init.sh

RUN chmod +x /usr/local/bin/init.sh

ENTRYPOINT ["/usr/local/bin/init.sh"]
