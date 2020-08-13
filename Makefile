#!/usr/bin/make

.PHONY: env

# Paramètres obligatoires
APP_ENVIRONMENT := localhost
DB_DUMP_FILENAME =./db/sql/current.sql

# Chargement de la configuration environnementale
include ./env/$(APP_ENVIRONMENT).env
export $(shell sed 's/=.*//' ./env/$(APP_ENVIRONMENT).env)

# Paramètres extrapolés
COMPOSE_PROJECT_PREFIX = $(subst .,,$(COMPOSE_PROJECT_NAME))

# Commandes publiques

## Misc

help: ## Affichage de ce message d'aide
	@printf "\033[36m%s\033[0m (v%s)\n\n" $$(basename $$(pwd)) $$(git describe --tags --always)
	@echo "Commandes disponibles\n"
	@for MKFILE in $(MAKEFILE_LIST); do \
		grep -E '^[a-zA-Z0-9\._-]+:.*?## .*$$' $$MKFILE | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-30s\033[0m  %s\n", $$1, $$2}'; \
	done
	@echo ""
	@$(MAKE) --no-print-directory urls

## Contrôle des conteneurs

clean: envsubst stop ## Suppression des conteneurs. Les volumes Docker sont conservés
	docker-compose rm -f

dev: env envsubst clean build  ## Démarrage de l'application et des outils de développement
	DIRECTUS_DATABASE_DUMP=$(DIRECTUS_DATABASE_DUMP) \
	MYSQL_WAIT_TIMEOUT=$(MYSQL_WAIT_TIMEOUT) \
	docker-compose \
		-f docker-compose.yml \
		-f docker-compose.dev.yml \
			up \
			--remove-orphans \
			-d
	@$(MAKE) --no-print-directory urls

logs: envsubst  ## Affiche un flux des logs de conteneurs de l'application
	docker-compose logs -f

start: pre-start envsubst ## Démarrage de l'application
	DIRECTUS_DATABASE_DUMP=$(DIRECTUS_DATABASE_DUMP) \
	MYSQL_WAIT_TIMEOUT=$(MYSQL_WAIT_TIMEOUT) \
	docker-compose up \
		--remove-orphans \
		-d

stop: envsubst ## Arrêt de l'application
	docker-compose stop

prune: envsubst ## Purge des artefacts créés par Docker. ATTENTION : les volumes Docker sont supprimés
	docker-compose down \
		--remove-orphans \
		--rmi local
	docker volume rm \
		$(COMPOSE_PROJECT_PREFIX)_db \
		$(COMPOSE_PROJECT_PREFIX)_directus_uploads

## Gestion de la base de données

db-dump: envsubst ## Exporte le schéma de la base de données
	# Démarrage du serveur de base de données
	docker-compose up -d db
	sleep 30

	# Tables Directus : schéma et données
	docker-compose run --rm --entrypoint mysqldump db \
		-u${DIRECTUS_DATABASE_USERNAME} \
		-p${DIRECTUS_DATABASE_PASSWORD} \
		-h${DIRECTUS_DATABASE_HOST} \
		${DIRECTUS_DATABASE_NAME} \
		$(DB_DUMP_FULL) > $(DB_DUMP_FILENAME)

	# Tables Directus : schéma uniquement
	docker-compose run --rm --entrypoint mysqldump db \
		-u${DIRECTUS_DATABASE_USERNAME} \
		-p${DIRECTUS_DATABASE_PASSWORD} \
		-h${DIRECTUS_DATABASE_HOST} \
		--no-data \
		${DIRECTUS_DATABASE_NAME} $(DB_DUMP_EMPTY) >> $(DB_DUMP_FILENAME)

	# Toutes les autres tables : schéma uniquement
	if [ ! -z "$(shell docker-compose run --rm --entrypoint mysql db --batch --silent -u${DIRECTUS_DATABASE_USERNAME} -p${DIRECTUS_DATABASE_PASSWORD} -h${DIRECTUS_DATABASE_HOST} ${DIRECTUS_DATABASE_NAME} --execute "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '${DIRECTUS_DATABASE_NAME}' AND TABLE_NAME NOT LIKE 'directus_%'")" ]; then \
		docker-compose run --rm --entrypoint mysqldump db \
			-u${DIRECTUS_DATABASE_USERNAME} \
			-p${DIRECTUS_DATABASE_PASSWORD} \
			-h${DIRECTUS_DATABASE_HOST} \
			--no-data \
			${DIRECTUS_DATABASE_NAME} \
			$(shell docker-compose run --rm --entrypoint mysql db --batch --silent -u${DIRECTUS_DATABASE_USERNAME} -p${DIRECTUS_DATABASE_PASSWORD} -h${DIRECTUS_DATABASE_HOST} ${DIRECTUS_DATABASE_NAME} --execute "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '${DIRECTUS_DATABASE_NAME}' AND TABLE_NAME NOT LIKE 'directus_%'") \
				>> $(DB_DUMP_FILENAME); \
	fi

# Commandes privées

build: # Construction des images Docker de l'application
	docker-compose build

clear-ports: # Arrêt des services utilisant le port 8080
	@for CONTAINER_ID in $$(docker ps --filter=expose=80 -q); do \
		if docker port $${CONTAINER_ID} | grep 80; then \
			docker stop $${CONTAINER_ID}; \
		fi; \
	done

env: # Génération du fichier .env courant en fonction de l'environnement d'exécution
	cat ./env/$(APP_ENVIRONMENT).env > ./.env

envsubst: # Regénération des fichiers dépendants de la configuration environnementale
	rm -f docker-compose.yml
	envsubst < docker-compose.dev.yml.dist > docker-compose.dev.yml
	envsubst < docker-compose.yml.dist > docker-compose.yml

pre-start: portainer-rm clear-ports # Commandes exécutées avant un démarrage de l'application

portainer-rm: # Suppression d'instances de Portainer existantes
	-docker rm -f portainer

urls: # Affichage de la liste des URL publiques
	@echo "URL publiques"
	@echo
	@echo "  Application"
	@echo
	@echo "    \033[36mDirectus\033[0m : http://directus.${APP_FQDN}"
	@echo
	@echo "  Outils"
	@echo
	@echo "    \033[36mAdminer\033[0m : http://adminer.${APP_FQDN}"
	@echo "    \033[36mPortainer\033[0m : http://portainer.${APP_FQDN}"
	@echo "    \033[36mTraefik\033[0m : http://traefik.${APP_FQDN}"
