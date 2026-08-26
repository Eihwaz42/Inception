# Base image
FROM debian:bookworm

# Install MariaDB and remove the apt cache
RUN apt-get update \
    && apt-get install -y mariadb-server \
    && rm -rf /var/lib/apt/lists/*

# Copy the MariaDB configuration file into the image
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy the initialization script
COPY tools/init.sh /usr/local/bin/init.sh

# Make the initialization script executable
RUN chmod +x /usr/local/bin/init.sh

# Run the initialization script when the container starts
ENTRYPOINT ["/usr/local/bin/init.sh"]