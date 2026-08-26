# Base image
FROM debian:bookworm

# php-fpm: executes the PHP code used by WordPress
# php-mysql: allows PHP to communicate with MariaDB
# mariadb-client: provides client tools to communicate with MariaDB
# curl: used to download WP-CLI
RUN apt-get update \
    && apt-get install -y \
        php-fpm \
        php-mysql \
        mariadb-client \
        curl \
    && rm -rf /var/lib/apt/lists/*

# Install WP-CLI, the command-line interface used to configure WordPress
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Copy the PHP-FPM configuration
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# Copy the WordPress initialization script
COPY tools/init.sh /usr/local/bin/init.sh

# Make the initialization script executable
RUN chmod +x /usr/local/bin/init.sh

# Run the initialization script when the container starts
ENTRYPOINT ["/usr/local/bin/init.sh"]