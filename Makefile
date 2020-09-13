#!/usr/bin/make

# Paramétrage de make
.PHONY: env

# Paramètres obligatoires
APP_ENVIRONMENT = localhost
DB_DUMP_FILENAME = ./db/sql/current.sql

# Chargement de la configuration environnementale
include .cicd/env/$(APP_ENVIRONMENT).env
export $(shell sed 's/=.*//' .cicd/env/$(APP_ENVIRONMENT).env)
export $(shell APP_ENVIRONMENT=$(APP_ENVIRONMENT))

# Paramètres extrapolés
COMPOSE_PROJECT_PREFIX = $(subst .,,$(COMPOSE_PROJECT_NAME))

# Commandes publiques

## Misc

help: ## Affichage de ce message d'aide
	@printf "\033[36m%s\033[0m (v%s)\n\n" $$(basename $$(pwd)) $$(git describe --tags --always)
	@echo "Commandes\n"
	@for MKFILE in $(MAKEFILE_LIST); do \
		grep -E '^[a-zA-Z0-9\._-]+:.*?## .*$$' $$MKFILE | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-30s\033[0m  %s\n", $$1, $$2}'; \
	done
	@echo ""
	@$(MAKE) --no-print-directory urls

## Contrôle des conteneurs

clean: envsubst stop ## Suppression des conteneurs. Les volumes Docker sont conservés
	docker-compose \
		-f docker-compose.yml \
		-f .cicd/docker-compose/dev.yml \
			rm -f

dev: env envsubst clean build  ## Démarrage de l'application et des outils de développement
	DIRECTUS_DATABASE_DUMP=$(DIRECTUS_DATABASE_DUMP) \
	MYSQL_WAIT_TIMEOUT=$(MYSQL_WAIT_TIMEOUT) \
	docker-compose \
		-f docker-compose.yml \
		-f .cicd/docker-compose/dev.yml \
			up \
			--remove-orphans \
			-d
	timeout -s TERM 60 bash -c \
		'while [[ "$$(curl -s -o /dev/null -L -w ''%{http_code}'' $(DIRECTUS_HOSTNAME))" != "200" ]]; do \
			echo "Waiting for $(DIRECTUS_HOSTNAME)" && sleep 2;\
		done'
	@$(MAKE) --no-print-directory help

logs: envsubst  ## Affiche un flux des logs de conteneurs de l'application
	docker-compose \
		-f docker-compose.yml \
		-f .cicd/docker-compose/dev.yml \
			logs -f

start: pre-start envsubst ## Démarrage de l'application
	DIRECTUS_DATABASE_DUMP=$(DIRECTUS_DATABASE_DUMP) \
	MYSQL_WAIT_TIMEOUT=$(MYSQL_WAIT_TIMEOUT) \
	docker-compose up \
		--remove-orphans \
		-d

stop: envsubst ## Arrêt de l'application
	docker-compose \
		-f docker-compose.yml \
		-f .cicd/docker-compose/dev.yml \
			stop

prune: clean ## Purge des artefacts créés par Docker. ATTENTION : les volumes Docker sont supprimés
	-docker volume rm \
		$(COMPOSE_PROJECT_PREFIX)_db \
		$(COMPOSE_PROJECT_PREFIX)_directus_uploads
	-docker network rm $(COMPOSE_PROJECT_PREFIX)_default

## Gestion de la base de données

db-dump: envsubst ## Exporte le schéma de la base de données (NB : ne fonctionne pas dans le terminal VS Code)
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

env: # Génération du fichier .env courant en fonction de l'environnement d'exécution
	cat .cicd/env/$(APP_ENVIRONMENT).env > ./.env
	echo "APP_ENVIRONMENT=$(APP_ENVIRONMENT)" >> ./.env

envsubst: # Regénération des fichiers dépendants de la configuration environnementale
	rm -f docker-compose.yml
	envsubst < .cicd/docker-compose/dev.yml.dist > .cicd/docker-compose/dev.yml
	envsubst < docker-compose.yml.dist > docker-compose.yml

urls: # Affichage de la liste des URL publiques
	@echo "Services"
	@echo
	@echo "  Application"
	@echo
	@echo "    \033[36mDirectus\033[0m : http://$(DIRECTUS_HOSTNAME)"
	@echo
	@echo "  Développement"
	@echo
	@echo "    \033[36mAdminer\033[0m : http://$(ADMINER_HOSTNAME)"
