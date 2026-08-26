COMPOSE = docker compose -f srcs/docker-compose.yml

# Construit les images et démarre les conteneurs
all:
	$(COMPOSE) up -d --build

# Arrête et supprime les conteneurs et le réseau
# Les volumes et leurs données sont conservés
down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down

# Supprime conteneurs, réseau, volumes Docker et données persistantes
fclean:
	$(COMPOSE) down -v

re: fclean all

.PHONY: all data down clean fclean re