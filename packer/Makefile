ENV ?= lab199
TEMPLATE_CONFIG ?= 002-ubuntu-2204 

ROOT_DIR = ..
PKR_VAR = environments/$(ENV)/template.pkrvars.hcl

.PHONY: image validate

validate:
	@echo "=> Validate configurations..."
	cd $(TEMPLATE_CONFIG) && \
		packer validate --var-file=$(ROOT_DIR)/$(PKR_VAR) .
image:
	@echo "=> Building image..."
	cd $(TEMPLATE_CONFIG) && \
		PACKER_LOG=1 packer build --var-file=$(ROOT_DIR)/$(PKR_VAR) .