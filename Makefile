FIG=docker-compose
RUN=$(FIG) run --rm
EXEC=$(FIG) exec
CONSOLE=php bin/console

.PHONY: help start stop build up reset config db-diff db-migrate vendor reload test

help:
	@echo "Please use \`make <target>' where <target> is one of"
	@echo "  reload   clear cache, reload database schema and load fixtures (only for dev environment)"

##
## Docker
##---------------------------------------------------------------------------

start:          ## Install and start the project
start: build up

stop:           ## Remove docker containers
	$(FIG) kill
	$(FIG) rm -v --force

reset:          ## Reset the whole project
reset: stop start

build:
	$(FIG) build

up:
	$(FIG) up -d

vendor:           ## Vendors
	$(RUN) php-cli composer install
	$(RUN) php-cli npm install

config:        ## Init files required
	cp -n .env.dist .env
	cp -n docker-compose.override.yml.dist docker-compose.override.yml

install:          ## Install the whole project
install: config start vendor reload

clear:          ## Remove all the cache, the logs, the sessions and the built assets
	$(EXEC) php-cli rm -rf var/cache/*
	$(EXEC) php-cli rm -rf var/logs/*

##
## DB
##---------------------------------------------------------------------------

db-diff:      ## Generation doctrine diff
	$(RUN) php-cli $(CONSOLE) doctrine:migrations:diff

db-migrate:   ## Launch doctrine migrations
	$(RUN) php-cli $(CONSOLE) doctrine:migrations:migrate -n

## Others
reload: clear reload-db

reload-db:
	$(RUN) php-cli $(CONSOLE) doctrine:database:drop --force
	$(RUN) php-cli $(CONSOLE) doctrine:database:create

