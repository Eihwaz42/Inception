# Base image
FROM debian:bookworm

# Install NGINX and OpenSSL, then remove the apt cache
RUN apt-get update \
    && apt-get install -y \
        nginx \
        openssl \
    && rm -rf /var/lib/apt/lists/*

# Copy the NGINX configuration file into the image
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Generate a self-signed TLS certificate
RUN mkdir -p /etc/nginx/ssl \
    && openssl req -x509 -nodes \
        -out /etc/nginx/ssl/inception.crt \
        -keyout /etc/nginx/ssl/inception.key \
        -subj "/C=CH/ST=Vaud/L=Lausanne/O=42/OU=42/CN=llabatut.42.fr"

# Run NGINX in the foreground so it remains the container's main process
ENTRYPOINT ["nginx", "-g", "daemon off;"]