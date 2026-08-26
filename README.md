*This project has been created as part of the 42 curriculum by llabatut.*

# Inception

## Description

Inception is a system administration project based on Docker.

The goal of the project is to build and run a small web infrastructure composed of several services, with each service running in its own Docker container.

The infrastructure contains:

- NGINX as the only public entry point, using HTTPS with TLS 1.2 and TLS 1.3.
- WordPress running with PHP-FPM.
- MariaDB as the database used by WordPress.
- A dedicated Docker network connecting the services.
- Two Docker named volumes used to persist the WordPress files and the MariaDB database.

The Docker images are built from Debian-based Dockerfiles provided in this repository. No pre-built WordPress, MariaDB or NGINX application image is used.

### Main design choices

Each main service runs in a separate container. Only NGINX exposes a port to the host machine. WordPress communicates with MariaDB through the Docker network, while NGINX communicates with WordPress through PHP-FPM.

Persistent data is stored using Docker named volumes. Docker's data root is configured under `/home/llabatut/data` on the host.

### Virtual Machines vs Docker

A virtual machine emulates a complete machine and runs its own operating system and kernel. Docker containers share the host kernel and isolate applications and their dependencies.

Virtual machines generally provide stronger isolation but require more resources. Containers are lighter and faster to create and restart, which makes them convenient for separating the services of this project.

### Secrets vs Environment Variables

Environment variables provide configuration values to processes at runtime. They are convenient, but sensitive values can be exposed through configuration or container inspection if they are not handled carefully.

Docker secrets are specifically intended for sensitive information and provide more controlled access to credentials.

In this project, configuration values are loaded from a local `.env` file which is excluded from Git. An `.env.example` file documents the required variables without containing real credentials.

### Docker Network vs Host Network

A Docker network provides an isolated network in which containers can communicate using their service names.

Host networking removes this network isolation and makes a container use the host network directly.

This project uses a dedicated Docker bridge network named `inception`. MariaDB and WordPress are not directly exposed on the host. Only NGINX publishes port 443.

### Docker Volumes vs Bind Mounts

Docker volumes are managed by Docker and are independent from the lifecycle of individual containers.

Bind mounts directly map a specific host path into a container and therefore depend more closely on the host filesystem layout.

This project uses Docker named volumes for the persistent MariaDB database and WordPress files. Bind mounts are not used for these persistent storages.

## Instructions

### Prerequisites

The machine must have:

- Docker
- Docker Compose
- Make

The domain `llabatut.42.fr` must resolve to the machine running the project.

A `.env` file must be created in the `srcs` directory using `.env.example` as a template.

### Build and start

From the root of the repository:

    make

This builds the Docker images and starts the infrastructure.

The website is then available at:

    https://llabatut.42.fr

The WordPress administration panel is available at:

    https://llabatut.42.fr/wp-admin

### Stop

To stop and remove the containers and network while keeping persistent volumes:

    make down

To remove the containers, network and project volumes:

    make fclean

To rebuild the project from a clean state:

    make re

## Resources

### Official documentation

- Docker Compose documentation: https://docs.docker.com/reference/compose-file/
- NGINX documentation: https://nginx.org/en/docs/
- MariaDB documentation: https://mariadb.com/docs
- WordPress documentation: https://wordpress.org/documentation/

### Articles and guides

- What is Docker?: https://devopscube.com/what-is-docker/
- Inception 42 – A Comprehensive Guide to Dockerizing Your First Infrastructure:
  https://devabdilah.medium.com/inception-42-a-comprehensive-guide-to-dockerizing-your-first-infrastructure-part-i-bd7d4bdc13e6
- WordPress deployment with NGINX, PHP-FPM and MariaDB using Docker Compose:
  https://medium.com/swlh/wordpress-deployment-with-nginx-php-fpm-and-mariadb-using-docker-compose-55f59e5c1a

### Example repositories

- https://github.com/azedineouhadou/inception-42
- https://github.com/vbachele/Inception

### AI usage

AI was used as a learning and debugging assistant during the project.

It was used to:
- explain Docker and Docker Compose concepts;
- help understand container networking and persistent volumes;
- explain NGINX, PHP-FPM and MariaDB configuration;
- review shell scripts and configuration files;
- prepare verification commands and project documentation.

The generated suggestions were reviewed, tested and adapted to the actual project environment before being used.