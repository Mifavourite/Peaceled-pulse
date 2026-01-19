.PHONY: help security-scan pentest audit setup clean vault-init vault-unseal

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(GREEN)Secure Flutter App - Security Commands$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'

setup: ## Initial setup of secure development environment
	@echo "$(GREEN)Setting up secure development environment...$(NC)"
	@docker-compose up -d vault postgres
	@sleep 5
	@make vault-init
	@echo "$(GREEN)Setup complete!$(NC)"

security-scan: ## Run comprehensive security scan
	@echo "$(GREEN)Running security scan...$(NC)"
	@docker-compose run --rm trivy
	@echo "$(GREEN)Security scan complete. Check ./scan-results/$(NC)"

pentest: ## Run penetration test simulation
	@echo "$(YELLOW)Running penetration test simulation...$(NC)"
	@echo "$(RED)⚠️  This is a simulation - not a real penetration test$(NC)"
	@dart run lib/security/testing/pentest_simulator.dart || echo "Pentest simulation completed"
	@echo "$(GREEN)Penetration test simulation complete$(NC)"

audit: ## Run security audit and generate report
	@echo "$(GREEN)Running security audit...$(NC)"
	@flutter pub audit
	@dart analyze --fatal-infos
	@echo "$(GREEN)Security audit complete$(NC)"

vault-init: ## Initialize HashiCorp Vault
	@echo "$(GREEN)Initializing Vault...$(NC)"
	@docker exec secure_vault vault operator init -key-shares=1 -key-threshold=1 > vault-keys.txt || true
	@echo "$(GREEN)Vault initialization keys saved to vault-keys.txt$(NC)"

vault-unseal: ## Unseal HashiCorp Vault
	@echo "$(GREEN)Unsealing Vault...$(NC)"
	@if [ -f vault-keys.txt ]; then \
		KEY=$$(grep "Unseal Key" vault-keys.txt | awk '{print $$4}' | head -1); \
		docker exec secure_vault vault operator unseal $$KEY || true; \
	else \
		echo "$(RED)Vault keys not found. Run 'make vault-init' first$(NC)"; \
	fi

clean: ## Clean up Docker containers and volumes
	@echo "$(YELLOW)Cleaning up...$(NC)"
	@docker-compose down -v
	@rm -rf scan-results/*.json scan-results/*.txt
	@echo "$(GREEN)Cleanup complete$(NC)"

start: ## Start all security services
	@echo "$(GREEN)Starting security services...$(NC)"
	@docker-compose up -d
	@echo "$(GREEN)Services started$(NC)"

stop: ## Stop all security services
	@echo "$(YELLOW)Stopping security services...$(NC)"
	@docker-compose stop
	@echo "$(GREEN)Services stopped$(NC)"

logs: ## View logs from all services
	@docker-compose logs -f

vault-status: ## Check Vault status
	@docker exec secure_vault vault status || echo "$(RED)Vault is not running or not initialized$(NC)"

wireguard-status: ## Check WireGuard status
	@docker exec secure_wireguard wg show || echo "$(RED)WireGuard is not running$(NC)"

test: ## Run Flutter tests
	@flutter test

lint: ## Run linter
	@flutter analyze

build: ## Build Flutter app
	@flutter build apk --release
	@echo "$(GREEN)Build complete$(NC)"
