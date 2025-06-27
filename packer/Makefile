ENV ?= lab199
TEMPLATE_CONFIG ?= 002-ubuntu-2204 

ROOT_DIR = ..
PKR_VAR = environments/$(ENV)/template.pkrvars.hcl

.PHONY: init validate image

init:
	@echo "=> Initialing configurations..."
	docker compose -f docker-compose.yml run --rm packer "\
		cd $(TEMPLATE_CONFIG) && \
			packer init ."

validate:
	@echo "=> Validating configurations..."
	docker compose -f docker-compose.yml run --rm packer "\
		cd $(TEMPLATE_CONFIG) && \
			packer validate --var-file=$(ROOT_DIR)/$(PKR_VAR) ."
image:
	@echo "=> Building image..."
	docker compose -f docker-compose.yml run --rm packer "\
		cd $(TEMPLATE_CONFIG) && \
			PACKER_LOG=1 packer build --var-file=$(ROOT_DIR)/$(PKR_VAR) ."