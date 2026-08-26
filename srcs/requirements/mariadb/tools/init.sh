#!/bin/bash

set -e # si une commande échoue, arrête le script

# Crée le dossier nécessaire au socket/PID de MariaDB
# et donne les bons droits à l'utilisateur mysql
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld /var/lib/mysql

# Initialise les fichiers système MariaDB uniquement s'ils sont absents
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

# Initialise NOTRE base Inception uniquement au premier démarrage
# Le fichier .inception_initialized sert de marqueur
if [ ! -f "/var/lib/mysql/.inception_initialized" ]; then

    # Démarre temporairement MariaDB en arrière-plan
    # sans accepter de connexions réseau
    mysqld_safe --skip-networking &
    pid="$!" # récupère le PID du processus lancé en arrière-plan

    # Attend que MariaDB soit prêt avant d'exécuter les commandes SQL
    until mariadb-admin ping --silent; do
        sleep 1
    done

    # Crée la DB WordPress, son utilisateur et configure root
    mariadb <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    # Arrête proprement l'instance temporaire avec le nouveau mot de passe root
    mariadb-admin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
    wait "$pid" # attend que le processus temporaire soit complètement terminé

    # Crée un marqueur pour ne pas refaire l'initialisation
    # lors des prochains démarrages
    touch /var/lib/mysql/.inception_initialized
fi

# Lance le vrai processus MariaDB au premier plan
# exec permet à mysqld de devenir le processus principal (PID 1) du conteneur
exec mysqld --user=mysql


# container démarre
#        ↓
# fichiers système MariaDB présents ?
#      ↙                         ↘
#    NON                         OUI
#     ↓                           │
# mariadb-install-db              │
#      ↘                         ↙
#   .inception_initialized existe ?
#          ↙              ↘
#        NON              OUI
#         ↓                │
# démarre MariaDB          │
# temporairement           │
#         ↓                │
# attend qu'il soit prêt   │
#         ↓                │
# crée DB WordPress        │
# + utilisateur wpuser     │
# + configure root         │
#         ↓                │
# arrête MariaDB temporaire│
#         ↓                │
# crée le marqueur         │
# .inception_initialized   │
#          ↘              ↙
#             exec mysqld
#                 ↓
#         MariaDB reste vivant