# Docker Services:
#   up - Start services (use: make up [service...] or make up MODE=prod, ARGS="--build" for options)
#   down - Stop services (use: make down [service...] or make down MODE=prod, ARGS="--volumes" for options)
#   build - Build containers (use: make build [service...] or make build MODE=prod)
#   logs - View logs (use: make logs [service] or make logs SERVICE=backend, MODE=prod for production)
#   restart - Restart services (use: make restart [service...] or make restart MODE=prod)
#   shell - Open shell in container (use: make shell [service] or make shell SERVICE=gateway, MODE=prod, default: backend)
#   ps - Show running containers (use MODE=prod for production)
#
# Convenience Aliases (Development):
#   dev-up - Alias: Start development environment
#   dev-down - Alias: Stop development environment
#   dev-build - Alias: Build development containers
#   dev-logs - Alias: View development logs
#   dev-restart - Alias: Restart development services
#   dev-shell - Alias: Open shell in backend container
#   dev-ps - Alias: Show running development containers
#   backend-shell - Alias: Open shell in backend container
#   gateway-shell - Alias: Open shell in gateway container
#   mongo-shell - Open MongoDB shell
#
# Convenience Aliases (Production):
#   prod-up - Alias: Start production environment
#   prod-down - Alias: Stop production environment
#   prod-build - Alias: Build production containers
#   prod-logs - Alias: View production logs
#   prod-restart - Alias: Restart production services
#
# Backend:
#   backend-build - Build backend TypeScript
#   backend-install - Install backend dependencies
#   backend-type-check - Type check backend code
#   backend-dev - Run backend in development mode (local, not Docker)
#
# Database:
#   db-reset - Reset MongoDB database (WARNING: deletes all data)
#   db-backup - Backup MongoDB database
#
# Cleanup:
#   clean - Remove containers and networks (both dev and prod)
#   clean-all - Remove containers, networks, volumes, and images
#   clean-volumes - Remove all volumes
#
# Utilities:
#   status - Alias for ps
#   health - Check service health
#
# Help:
#   help - Display this help message

.PHONY: help up down build logs restart shell ps clean clean-all clean-volumes
.PHONY: dev-up dev-down dev-build dev-logs dev-restart dev-shell dev-ps
.PHONY: prod-up prod-down prod-build prod-logs prod-restart
.PHONY: backend-shell gateway-shell mongo-shell backend-build backend-install backend-type-check backend-dev
.PHONY: db-reset db-backup status health

# Default target
.DEFAULT_GOAL := help

# Variables
MODE ?= dev
SERVICE ?= backend
ARGS ?=
COMPOSE_FILE_DEV = docker/compose.development.yaml
COMPOSE_FILE_PROD = docker/compose.production.yaml

# Determine compose file based on MODE
ifeq ($(MODE),prod)
	COMPOSE_FILE = $(COMPOSE_FILE_PROD)
	ENV_MODE = production
else
	COMPOSE_FILE = $(COMPOSE_FILE_DEV)
	ENV_MODE = development
endif

# Docker Compose command
DC = docker compose -f $(COMPOSE_FILE) --env-file .env

# Colors for output
GREEN = \033[0;32m
YELLOW = \033[1;33m
RED = \033[0;31m
NC = \033[0m # No Color

##@ General

help: ## Display this help message
	@echo "$(GREEN)E-Commerce DevOps Makefile Commands$(NC)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make $(YELLOW)<target>$(NC)\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(YELLOW)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Docker Services

up: ## Start services (MODE=dev|prod, ARGS="--build")
	@echo "$(GREEN)Starting $(ENV_MODE) environment...$(NC)"
	@if [ ! -f .env ]; then echo "$(RED)Error: .env file not found. Copy .env.example to .env$(NC)" && exit 1; fi
	$(DC) up -d $(ARGS) $(filter-out $@,$(MAKECMDGOALS))

down: ## Stop services (MODE=dev|prod, ARGS="--volumes")
	@echo "$(YELLOW)Stopping $(ENV_MODE) environment...$(NC)"
	$(DC) down $(ARGS) $(filter-out $@,$(MAKECMDGOALS))

build: ## Build containers (MODE=dev|prod)
	@echo "$(GREEN)Building $(ENV_MODE) containers...$(NC)"
	$(DC) build $(filter-out $@,$(MAKECMDGOALS))

logs: ## View logs (MODE=dev|prod, SERVICE=backend|gateway|mongo)
	$(DC) logs -f $(SERVICE)

restart: ## Restart services (MODE=dev|prod)
	@echo "$(YELLOW)Restarting $(ENV_MODE) services...$(NC)"
	$(DC) restart $(filter-out $@,$(MAKECMDGOALS))

shell: ## Open shell in container (MODE=dev|prod, SERVICE=backend)
	$(DC) exec $(SERVICE) sh

ps: ## Show running containers (MODE=dev|prod)
	$(DC) ps

status: ps ## Alias for ps

##@ Development Aliases

dev-up: ## Start development environment
	@$(MAKE) up MODE=dev

dev-down: ## Stop development environment
	@$(MAKE) down MODE=dev

dev-build: ## Build development containers
	@$(MAKE) build MODE=dev

dev-logs: ## View development logs
	@$(MAKE) logs MODE=dev

dev-restart: ## Restart development services
	@$(MAKE) restart MODE=dev

dev-shell: ## Open shell in backend container (dev)
	@$(MAKE) shell MODE=dev SERVICE=backend

dev-ps: ## Show running development containers
	@$(MAKE) ps MODE=dev

backend-shell: ## Open shell in backend container
	@$(MAKE) shell SERVICE=backend

gateway-shell: ## Open shell in gateway container
	@$(MAKE) shell SERVICE=gateway

mongo-shell: ## Open MongoDB shell
	@echo "$(GREEN)Opening MongoDB shell...$(NC)"
	$(DC) exec mongo mongosh -u $(shell grep MONGO_INITDB_ROOT_USERNAME .env | cut -d '=' -f2) -p $(shell grep MONGO_INITDB_ROOT_PASSWORD .env | cut -d '=' -f2)

##@ Production Aliases

prod-up: ## Start production environment
	@$(MAKE) up MODE=prod

prod-down: ## Stop production environment
	@$(MAKE) down MODE=prod

prod-build: ## Build production containers
	@$(MAKE) build MODE=prod

prod-logs: ## View production logs
	@$(MAKE) logs MODE=prod

prod-restart: ## Restart production services
	@$(MAKE) restart MODE=prod

##@ Backend Development

backend-build: ## Build backend TypeScript
	@echo "$(GREEN)Building backend...$(NC)"
	cd backend && npm run build

backend-install: ## Install backend dependencies
	@echo "$(GREEN)Installing backend dependencies...$(NC)"
	cd backend && npm install

backend-type-check: ## Type check backend code
	@echo "$(GREEN)Type checking backend...$(NC)"
	cd backend && npm run type-check

backend-dev: ## Run backend in development mode (local, not Docker)
	@echo "$(GREEN)Starting backend in development mode...$(NC)"
	cd backend && npm run dev

##@ Database

db-reset: ## Reset MongoDB database (WARNING: deletes all data)
	@echo "$(RED)WARNING: This will delete all data!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo "$(YELLOW)Resetting database...$(NC)"; \
		$(MAKE) down MODE=$(MODE) ARGS="--volumes"; \
		$(MAKE) up MODE=$(MODE); \
	else \
		echo "$(GREEN)Cancelled.$(NC)"; \
	fi

db-backup: ## Backup MongoDB database
	@echo "$(GREEN)Backing up MongoDB database...$(NC)"
	@mkdir -p backups
	$(DC) exec mongo mongosh -u $(shell grep MONGO_INITDB_ROOT_USERNAME .env | cut -d '=' -f2) -p $(shell grep MONGO_INITDB_ROOT_PASSWORD .env | cut -d '=' -f2) --eval "db.getCollectionNames().forEach(function(c) { if (c.indexOf('system.') == -1) db[c].find().forEach(printjson); })" > backups/backup_$(shell date +%Y%m%d_%H%M%S).json
	@echo "$(GREEN)Backup completed!$(NC)"

##@ Cleanup

clean: ## Remove containers and networks (both dev and prod)
	@echo "$(YELLOW)Cleaning up containers and networks...$(NC)"
	docker compose -f $(COMPOSE_FILE_DEV) down
	docker compose -f $(COMPOSE_FILE_PROD) down

clean-all: ## Remove containers, networks, volumes, and images
	@echo "$(RED)WARNING: This will remove all containers, networks, volumes, and images!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo "$(YELLOW)Cleaning everything...$(NC)"; \
		docker compose -f $(COMPOSE_FILE_DEV) down --volumes --rmi all; \
		docker compose -f $(COMPOSE_FILE_PROD) down --volumes --rmi all; \
	else \
		echo "$(GREEN)Cancelled.$(NC)"; \
	fi

clean-volumes: ## Remove all volumes
	@echo "$(RED)WARNING: This will delete all data!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo "$(YELLOW)Removing volumes...$(NC)"; \
		docker compose -f $(COMPOSE_FILE_DEV) down --volumes; \
		docker compose -f $(COMPOSE_FILE_PROD) down --volumes; \
	else \
		echo "$(GREEN)Cancelled.$(NC)"; \
	fi

##@ Utilities

health: ## Check service health
	@echo "$(GREEN)Checking service health...$(NC)"
	@echo "\n$(YELLOW)Gateway health:$(NC)"
	@curl -s http://localhost:5921/health || echo "$(RED)Gateway not responding$(NC)"
	@echo "\n$(YELLOW)Backend health (via gateway):$(NC)"
	@curl -s http://localhost:5921/api/health || echo "$(RED)Backend not responding$(NC)"
	@echo ""

# Prevent make from treating arguments as targets
%:
	@:
