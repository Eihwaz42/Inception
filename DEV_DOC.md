# Developer Documentation

## Prerequisites

The project is designed to run inside a virtual machine.

The following tools must be installed on the host:

- Docker
- Docker Compose
- Make

The current user must be able to run Docker commands.

The domain name used by the project must resolve to the host running the Docker infrastructure.

For this project:

    llabatut.42.fr

## Repository Structure

The main project files are organized as follows:

    .
    ├── Makefile
    ├── README.md
    ├── USER_DOC.md
    ├── DEV_DOC.md
    └── srcs
        ├── .env
        ├── .env.example
        ├── docker-compose.yml
        └── requirements
            ├── mariadb
            │   ├── Dockerfile
            │   ├── conf
            │   │   └── 50-server.cnf
            │   └── tools
            │       └── init.sh
            │
            ├── nginx
            │   ├── Dockerfile
            │   └── conf
            │       └── nginx.conf
            │
            └── wordpress
                ├── Dockerfile
                ├── conf
                │   └── www.conf
                └── tools
                    └── init.sh

Each service has its own Dockerfile and configuration files.

## Development Environment Setup

### Install Required Packages

Update the package list:

```bash
sudo apt update
```

Install the required development and testing tools:

```bash
sudo apt install -y make git curl openssh-server openssl
```

These packages are used for:

- **Make**: running the project Makefile.
- **Git**: cloning and managing the repository.
- **curl**: testing the HTTPS endpoint.
- **OpenSSH Server**: connecting remotely to the virtual machine.
- **OpenSSL**: testing the TLS configuration.

Docker Engine and Docker Compose must also be installed according to the official Docker installation instructions for Debian.

Verify the installation:

```bash
make --version
git --version
curl --version
ssh -V
openssl version
docker --version
docker compose version
```

### SSH Access to the Virtual Machine

SSH can be used to work on the virtual machine remotely.

Install the SSH server if necessary:

```bash
sudo apt install -y openssh-server
```

Check that the SSH service is running:

```bash
sudo systemctl status ssh
```

Display the IP addresses of the virtual machine:

```bash
hostname -I
```

From the host machine, connect to the virtual machine with:

```bash
ssh llabatut@<VM_IP>
```

Replace `<VM_IP>` with the IP address of the virtual machine.

### Docker Permissions

To run Docker commands without `sudo`, add the current user to the `docker` group:

```bash
sudo usermod -aG docker $USER
```

The new group membership normally takes effect after logging out and logging back in.

It can also be applied to the current shell with:

```bash
newgrp docker
```

Verify that the user belongs to the `docker` group:

```bash
groups
```

Then verify that Docker can be accessed without `sudo`:

```bash
docker ps
```

### Configure Docker Data Storage

The project requires the persistent Docker data to be stored under:

```text
/home/llabatut/data
```

Create or edit the Docker daemon configuration:

```bash
sudo nano /etc/docker/daemon.json
```

Configure the Docker data root:

```json
{
  "data-root": "/home/llabatut/data"
}
```

If `/etc/docker/daemon.json` already contains other configuration options, add `data-root` to the existing JSON object instead of overwriting the file.

Restart Docker to apply the configuration:

```bash
sudo systemctl restart docker
```

Verify the new Docker data directory:

```bash
docker info | grep "Docker Root Dir"
```

Expected result:

```text
Docker Root Dir: /home/llabatut/data
```

Docker named volumes created by the project will consequently store their data under:

```text
/home/llabatut/data/volumes/
```

Their exact locations can be checked later with:

```bash
docker volume inspect srcs_mariadb_data
docker volume inspect srcs_wordpress_data
```

### GitHub SSH Configuration

To access a GitHub repository through SSH from the virtual machine, generate an SSH key on the VM:

```bash
ssh-keygen -t ed25519 -C "your-email@example.com"
```

Press Enter to use the default location:

```text
~/.ssh/id_ed25519
```

Display the public key:

```bash
cat ~/.ssh/id_ed25519.pub
```

Copy the displayed public key and add it to your GitHub account under:

**Settings → SSH and GPG keys → New SSH key**

Only the public key (`id_ed25519.pub`) must be shared. The private key (`id_ed25519`) must remain on the virtual machine.

Test the connection:

```bash
ssh -T git@github.com
```

On the first connection, SSH may ask whether the GitHub host should be trusted. Verify the fingerprint and accept it.

Once SSH authentication works, clone the repository:

```bash
cd ~
git clone git@github.com:<github-username>/Inception.git
cd Inception
```

The repository can then be managed normally from the virtual machine:

```bash
git pull
git status
git add .
git commit
git push
```

### Optional: VS Code Remote SSH

VS Code can be used to edit the project directly inside the virtual machine.

Install the **Remote - SSH** extension in VS Code.

On the host machine, edit the SSH configuration file:

```bash
nano ~/.ssh/config
```

Add an entry for the virtual machine:

```text
Host inception
    HostName <VM_IP>
    User llabatut
```

Replace `<VM_IP>` with the IP address of the virtual machine.

The virtual machine can then be opened from VS Code by connecting to the Remote SSH host named `inception`.

This configuration is optional and is not required to build or run the project.

### Domain Name Configuration

The WordPress website is configured to use the following domain:

```text
llabatut.42.fr
```

On the machine used to access the website, edit the hosts file:

```bash
sudo nano /etc/hosts
```

Add an entry mapping the IP address of the virtual machine to the project domain:

```text
<VM_IP>    llabatut.42.fr
```

For example:

```text
192.168.x.x    llabatut.42.fr
```

The exact IP address depends on the virtual machine network configuration and can be obtained from the VM with:

```bash
hostname -I
```

The domain mapping can be verified with:

```bash
getent hosts llabatut.42.fr
```

Once the infrastructure is running, the website can be accessed at:

```text
https://llabatut.42.fr
```

Because the project uses a self-signed TLS certificate, the browser may display a certificate warning.

## Environment Configuration

The project uses environment variables stored in:

    srcs/.env

This file contains local configuration and credentials and must not be committed to Git.

An example configuration is provided in:

    srcs/.env.example

Create the local environment file with:

    cp srcs/.env.example srcs/.env

Then edit `srcs/.env` and replace the example values with the appropriate configuration and credentials.

## Docker Data Storage

The project uses two Docker named volumes:

- `srcs_mariadb_data`
- `srcs_wordpress_data`

Bind mounts are not used for these persistent volumes.

Docker must be configured so that its persistent data is stored under:

    /home/llabatut/data

To configure the Docker data directory, create or edit:

    /etc/docker/daemon.json

and configure:

    {
      "data-root": "/home/llabatut/data"
    }

If `/etc/docker/daemon.json` already contains other Docker configuration, the `data-root` option must be added to the existing JSON object instead of overwriting it.

Restart Docker after changing the configuration:

    sudo systemctl restart docker

The configuration can be verified with:

    docker info | grep "Docker Root Dir"

The expected result is:

    Docker Root Dir: /home/llabatut/data

After the project volumes have been created, their locations can be checked with:

    docker volume inspect srcs_mariadb_data
    docker volume inspect srcs_wordpress_data

Their mountpoints should be located under:

    /home/llabatut/data/volumes/

## Building and Starting the Project

From the repository root, run:

    make

The Makefile uses Docker Compose to build the three Docker images and start the infrastructure.

The equivalent main Docker Compose command is:

    docker compose -f srcs/docker-compose.yml up -d --build

The first build can take several minutes because packages must be downloaded and installed inside the images.

Subsequent builds can reuse Docker's build cache.

## Managing the Infrastructure

To display running containers:

    docker ps

Three containers should be running:

- `nginx`
- `wordpress`
- `mariadb`

To stop and remove the containers and network while preserving the volumes:

    make down

To remove the containers, network and project volumes:

    make fclean

To rebuild the infrastructure from a clean project state:

    make re

## Docker Network

The services communicate through a dedicated Docker network.

It can be inspected with:

    docker network ls

The Compose network should appear as:

    srcs_inception

Only the NGINX container publishes a port to the host.

Its port configuration can be checked with:

    docker inspect nginx --format '{{json .NetworkSettings.Ports}}'

WordPress and MariaDB should not publish ports:

    docker inspect wordpress --format '{{json .NetworkSettings.Ports}}'
    docker inspect mariadb --format '{{json .NetworkSettings.Ports}}'

## Persistent Data

MariaDB stores its database inside:

    /var/lib/mysql

This directory is backed by the `mariadb_data` Docker named volume.

WordPress stores its files inside:

    /var/www/html

This directory is backed by the `wordpress_data` Docker named volume.

Because these are persistent Docker volumes, destroying and recreating the containers with:

    make down
    make

does not remove the website data.

Running:

    make fclean

removes the project volumes and therefore deletes the persistent MariaDB and WordPress data.

## Useful Debugging Commands

Display container status:

    docker ps -a

Display logs:

    docker logs mariadb
    docker logs wordpress
    docker logs nginx

Open a shell inside a container:

    docker exec -it mariadb bash
    docker exec -it wordpress bash
    docker exec -it nginx bash

Inspect the MariaDB database:

    docker exec -it mariadb mariadb -u root -p

Then, for example:

    SHOW DATABASES;
    SELECT User, Host FROM mysql.user;

Inspect the WordPress installation:

    docker exec -it wordpress bash
    cd /var/www/html
    wp core is-installed --allow-root
    wp user list --allow-root

Check the HTTPS endpoint:

    curl -k -I https://localhost

Check TLS 1.2:

    openssl s_client -connect localhost:443 -tls1_2 </dev/null

Check TLS 1.3:

    openssl s_client -connect localhost:443 -tls1_3 </dev/null