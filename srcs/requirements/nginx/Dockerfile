FROM debian:bookworm

RUN apt-get update \
    && apt-get install -y \
        nginx \
        openssl \
    && rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /etc/nginx/ssl \
    && openssl req -x509 -nodes \
        -out /etc/nginx/ssl/inception.crt \
        -keyout /etc/nginx/ssl/inception.key \
        -subj "/C=CH/ST=Vaud/L=Lausanne/O=42/OU=42/CN=llabatut.42.fr"

ENTRYPOINT ["nginx", "-g", "daemon off;"]