COMPOSE = docker compose -f srcs/docker-compose.yml

# Build the images and start the containers
all:
	$(COMPOSE) up -d --build

# Stop and remove the containers and network
# Persistent volumes and their data are preserved
down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down

# Remove containers, network and Docker volumes
fclean:
	$(COMPOSE) down -v

re: fclean all

.PHONY: all down clean fclean re