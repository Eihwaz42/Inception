#!/bin/bash

set -e # si une commande échoue, arrête le script

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld /var/lib/mysql

if [ ! -d "/var/lib/mysql/mysql" ]; then # si le dossier système de MariaDB n’existe pas… (1er démarrage)
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi
    
mysqld_safe --skip-networking & # démarre temporairement MariaDB en arrière-plan
pid="$!" # récupère le PID du dernier processus lancé en arrière-plan

# attend que MariaDB soit prêt avant d'exécuter les commandes SQL
until mariadb-admin ping --silent; do # TANT QUE MariaDB ne répond pas → attends 1 seconde → réessaie.
    sleep 1
done

mariadb <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

mariadb-admin shutdown # arrête proprement l'instance temporaire de MariaDB
wait "$pid" # attend que le processus temporaire soit complètement terminé

exec mysqld --user=mysql # lancer le vrai processus mariadb


# container démarre
#      ↓
# init.sh
#      ↓
# fichiers système MariaDB présents ?
#    ↙                        ↘
#  NON                       OUI
#  ↓                          │
# mariadb-install-db          │
#    ↘                       ↙
#      démarre MariaDB temporairement
#                ↓
#         attend qu'il soit prêt
#                ↓
#   crée DB + user si inexistants
#                ↓
#      arrête MariaDB temporaire
#                ↓
#         exec mysqld
#                ↓
#      MariaDB reste vivant