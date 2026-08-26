# User Documentation

## Services

The Inception stack provides three services:

- **NGINX**: the public entry point of the infrastructure. It serves the website over HTTPS on port 443 using TLS.
- **WordPress**: the content management system used to create and manage the website.
- **MariaDB**: the database used by WordPress to store website data.

Only NGINX is exposed directly to the host. WordPress and MariaDB communicate through the internal Docker network.

Persistent data is stored in two Docker named volumes:
- `srcs_wordpress_data` for WordPress files.
- `srcs_mariadb_data` for the MariaDB database.

## Starting the Project

From the root of the repository, run:

    make

This builds the required Docker images and starts all services.

To check that the containers are running:

    docker ps

The `nginx`, `wordpress` and `mariadb` containers should all have an `Up` status.

## Stopping the Project

To stop and remove the containers and Docker network while keeping persistent data:

    make down

The WordPress files and database remain stored in the Docker volumes and will be available the next time the project is started.

To remove the containers, network and project volumes:

    make fclean

Warning: `make fclean` removes the project volumes and therefore deletes the persistent WordPress and MariaDB data.

To rebuild the project from a clean state:

    make re

## Accessing the Website

The website is available at:

    https://llabatut.42.fr

The WordPress administration panel is available at:

    https://llabatut.42.fr/wp-admin

The TLS certificate used by the project is self-signed, so a browser may display a security warning when accessing the website.

## Credentials

Project credentials and configuration values are stored locally in:

    srcs/.env

This file must not be committed to Git.

The repository provides:

    srcs/.env.example

It can be used as a template showing which environment variables are required.

To configure the project, copy the example file:

    cp srcs/.env.example srcs/.env

Then replace the example values with the appropriate credentials.

Never store real passwords or other sensitive credentials in files committed to the repository.

## Checking the Services

To check the running containers:

    docker ps

The following containers should be running:

    nginx
    wordpress
    mariadb

Only NGINX should expose port 443 to the host.

To check the Docker network:

    docker network ls

The network `srcs_inception` should be present.

To check the persistent volumes:

    docker volume ls

The volumes `srcs_mariadb_data` and `srcs_wordpress_data` should be present.

To check the website from the command line:

    curl -k -I https://localhost

A successful response should return an HTTP status such as:

    HTTP/1.1 200 OK

Container logs can be inspected with:

    docker logs nginx
    docker logs wordpress
    docker logs mariadb