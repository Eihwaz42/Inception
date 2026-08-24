#Base image
FROM debian:bookworm

#Install Mariadb
#Remove apt cache to clean up
RUN apt-get update \
    && apt-get install -y mariadb-server \
    && rm -rf /var/lib/apt/lists/*

#copie un fichier du projet dans l’image
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/init.sh /usr/local/bin/init.sh

#sera exécuté quand le conteneur démarrera
RUN chmod +x /usr/local/bin/init.sh

ENTRYPOINT ["/usr/local/bin/init.sh"]