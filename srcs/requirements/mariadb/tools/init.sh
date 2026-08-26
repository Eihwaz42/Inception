#!/bin/bash

# Stop the script immediately if a command fails
set -e

# Create the directory required by MariaDB for its PID/socket
# and give the mysql user ownership of the required directories
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld /var/lib/mysql

# Initialize the MariaDB system files only if they do not already exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

# Initialize the Inception database only on the first startup
# The .inception_initialized file is used as an initialization marker
if [ ! -f "/var/lib/mysql/.inception_initialized" ]; then

    # Temporarily start MariaDB in the background
    # without accepting network connections
    mysqld_safe --skip-networking &
    pid="$!" # Store the PID of the background process

    # Wait until MariaDB is ready to accept commands
    until mariadb-admin ping --silent; do
        sleep 1
    done

    # Create the WordPress database and user, and configure root
    mariadb <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    # Gracefully stop the temporary MariaDB instance
    # using the newly configured root password
    mariadb-admin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
    wait "$pid"

    # Create the marker so initialization is not repeated
    # on subsequent container startups
    touch /var/lib/mysql/.inception_initialized
fi

# Start the real MariaDB process in the foreground
# exec makes mysqld the container's main process (PID 1)
exec mysqld --user=mysql


# Container starts
#        ↓
# MariaDB system files exist?
#      ↙                    ↘
#     NO                    YES
#      ↓                     │
# Initialize MariaDB         │
#      ↘                    ↙
# .inception_initialized exists?
#          ↙             ↘
#         NO             YES
#          ↓               │
# Start MariaDB            │
# temporarily              │
#          ↓               │
# Wait until ready         │
#          ↓               │
# Create WordPress DB      │
# + WordPress DB user      │
# + configure root         │
#          ↓               │
# Stop temporary MariaDB   │
#          ↓               │
# Create initialization    │
# marker                   │
#          ↘              ↙
#             exec mysqld
#                  ↓
#         MariaDB stays alive