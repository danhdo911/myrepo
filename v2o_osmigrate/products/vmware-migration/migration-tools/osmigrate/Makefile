#----------------------------------------------- INCLUDE .env #-----------------------------------------------#
ENV_FILE := environments/$(ENV)/.env

ifneq ($(wildcard $(ENV_FILE)),)
include $(ENV_FILE)
endif

export ENV

#----------------------------------------------- VARIABLES #-----------------------------------------------#
PROJECT_ROOT := $(abspath ../..)

PYTHON_LIBS ?= $(PROJECT_ROOT)/libs/python
export PYTHON_LIBS

IMAGE ?= vmware-migration-kit:latest

ENVIRONMENT_DIR ?= environments/$(ENV)
INVENTORY ?= $(ENVIRONMENT_DIR)/inventory
GROUP_VARS ?= $(ENVIRONMENT_DIR)/group_vars
DNS_VAR_FILE ?=$(GROUP_VARS)/dns.yml

ANSIBLE_PLAYBOOK_PATH ?= ansible/playbooks

MIGRATION_SETTINGS_FILE ?= $(ENVIRONMENT_DIR)/migration_settings.yml
MIGRATION_SECRETS_FILE ?= $(ENVIRONMENT_DIR)/secrets.yml
MIGRATION_VMW_DATA_DIR ?= $(VMWARE_DATA_DIR)
MIGRATION_CUTOVER ?= false

#----------------------------------------------- EXECUTES -----------------------------------------------#
#--------------------------------------------------------------------------------------------------------#
# Migration Infrastructure Preparation:
#	- Migrator Host: Linux host ready to run AEE and migration workflows.
#	- AEE Image: Built and validated image with required packages, Ansible collections, certificates, and patches.
#	- Conversion Host: CentOS Stream 10 host configured and ready for VM disk conversion and migration.

.PHONY: build_migrator \
		config_docker_proxy \
		build_aee \
		generate_inventoy \
		build_conversion deploy_conversion validate_aee_to_conv setup_conversion \
		validate_connectivity

configure_docker_proxy:
	@echo ""
	@echo "Configure Docker proxy..."
	@ENV_FILE="$(ENV_FILE)" \
		./infra_os_migrate/scripts/configure_docker_proxy.sh

build_migrator:
	@echo ""
	@echo "Building Migrator host..."
	@./infra_os_migrate/migrator/setup_migrator.sh
	@$(MAKE) configure_docker_proxy

build_aee:
	@echo ""
	@echo "Building Ansible Execution Environment (AEE) image..."
	@cd ./infra_os_migrate/aee && \
		CUSTOM_PATCHES=$(CUSTOM_PATCHES) \
		OS_MIGRATE_VERSION=$(OS_MIGRATE_VERSION) \
		./build_aee.sh

deploy_conversion:
	@echo ""
	@echo "Building Conversion host..."
	@docker compose -f docker-compose.yml run --rm --user 0:0 ansible "\
		ENV_FILE="$(ENV_FILE)" \
		CONVERSION_HOST_NAME="$(CONVERSION_HOST_NAME)" \
		CONVERSION_NETWORK="$(CONVERSION_NETWORK)" \
		CONVERSION_STATIC_IP="$(CONVERSION_STATIC_IP)" \
		CONVERSION_FLOATING_IP="$(CONVERSION_FLOATING_IP)" \
		./infra_os_migrate/conversion/deploy_conversion.sh \
	"

generate_inventory:
	@echo ""
	@echo "Generate Ansible inventory..."
	@ENV_FILE="$(ENV_FILE)" ./infra_os_migrate/ansible_inventory/generate_inventory.sh

validate_aee_to_conv:
	@echo ""
	@echo "Waiting for connection to the conversion host..."
	@docker compose -f docker-compose.yml run --rm --user 0:0 ansible "\
		ansible conversion_host \
			-m ansible.builtin.wait_for_connection \
			-a 'timeout=300 sleep=5 connect_timeout=10' \
			-i $(INVENTORY) \
			-v \
	"

	@echo ""
	@echo "Conversion host is reachable."

# Must download the VMware VDDK archive and located to /tmp in the migrator host.
setup_conversion:
	@echo ""
	@echo "Configuring the conversion host..."
	@docker compose -f docker-compose.yml run --rm --user 0:0 ansible "\
		ansible-playbook \
			$(ANSIBLE_PLAYBOOK_PATH)/setup_conversion.yml \
			-i $(INVENTORY) \
			-e @$(DNS_VAR_FILE) \
			-e @$(MIGRATION_SETTINGS_FILE) \
			-v \
	"

build_conversion: deploy_conversion generate_inventory validate_aee_to_conv setup_conversion

validate_connectivity:
	@echo ""
	@echo "Validating connection to VMware and OpenStack..."
	@docker compose -f docker-compose.yml run --rm --user 0:0 ansible "\
		ansible-playbook \
			$(ANSIBLE_PLAYBOOK_PATH)/validate_connectivity.yml \
			-i $(INVENTORY) \
			-v \
	"

#--------------------------------------------------------------------------------------------------------#
# Pre-Migration:
#	- Collect, filter the VM inventory and additional VM information, including resource pools and snapshots.
#	- Validate VM migration readiness based on the collected inventory.
# 	- Generate the migration variables for the migration step based on the VM migration readiness.

.PHONY: pre_migrate collect validate_inventory generate_vars

collect:
	@echo ""
	@echo "Collecting VM inventory from VMware..."
	@ENV_FILE="$(ENV_FILE)" ./collect_vm_inventory.sh

	@echo ""
	@echo "Collecting additional VM information..."
	@docker compose -f docker-compose.yml run --rm --user 0:0 ansible "\
		ansible-playbook \
			$(ANSIBLE_PLAYBOOK_PATH)/pre_migrate.yml \
			-i $(INVENTORY) \
			-e @$(MIGRATION_SECRETS_FILE) \
			-t data_collect \
			-v \
	"

validate_inventory:
	@echo ""
	@echo "Validating VM migration readiness..."
	@docker compose -f docker-compose.yml run --rm --user 0:0 ansible "\
		ansible-playbook \
			$(ANSIBLE_PLAYBOOK_PATH)/pre_migrate.yml \
			-i $(INVENTORY) \
			-t readiness_check \
			-v \
	"

generate_vars:
	@echo ""
	@echo "Generating migration variable file..."
	@docker compose -f docker-compose.yml run --rm --user 0:0 ansible "\
		ansible-playbook \
			$(ANSIBLE_PLAYBOOK_PATH)/pre_migrate.yml \
			-i $(INVENTORY) \
			-t migration_vars \
			-v \
	"

pre_migrate: collect validate_inventory generate_vars

#--------------------------------------------------------------------------------------------------------#
# Migrate VMs from VMware to OpenStack:
#	- Validate required input variable files: os_migrate.yml, migrations_vars.yml and secrets.yml
# 	- This task follows the migration workflow provided by the Red Hat os-migrate tool.

.PHONY: validate_migration_inputs migrate

validate_migration_inputs:
	@echo ""
	@echo "Validating migration input files..."
	@test -s "$(MIGRATION_SETTINGS_FILE)" || \
		{ echo "ERROR: Migration settings file is missing or empty: $(MIGRATION_SETTINGS_FILE)"; exit 1; }
	@echo "Validated: $(MIGRATION_SETTINGS_FILE)"

	@test -s "$(MIGRATION_VM_FILE)" || \
		{ echo "ERROR: Migration variables file is missing or empty: $(MIGRATION_VM_FILE)"; exit 1; }
	@echo "Validated: $(MIGRATION_VM_FILE)"

	@test -s "$(MIGRATION_SECRETS_FILE)" || \
		{ echo "ERROR: Secrets file is missing or empty: $(MIGRATION_SECRETS_FILE)"; exit 1; }
	@echo "Validated: $(MIGRATION_SECRETS_FILE)"

	@echo "All migration input files validated successfully."

migrate: validate_migration_inputs
	@echo ""
	@if [ -f "$(MIGRATION_VM_FILE)" ]; then \
		echo "Migrating VMs using $(MIGRATION_VM_FILE)..."; \
		docker compose -f docker-compose.yml run --rm --user 0:0 ansible "\
			ansible-playbook \
				os_migrate.vmware_migration_kit.migration \
				-i $(INVENTORY) \
				-e @$(MIGRATION_SECRETS_FILE) \
				-e @$(MIGRATION_SETTINGS_FILE) \
				-e @$(MIGRATION_VM_FILE) \
				-e '{"cutover": $(MIGRATION_CUTOVER)}' \
				-v \
		"; \
	else \
		echo "Skipping migration: $(MIGRATION_VM_FILE) does not exist."; \
	fi

migrate_vm_with_v2v:
	@$(MAKE) migrate MIGRATION_VM_FILE=$(ENVIRONMENT_DIR)/migration_vm_with_v2v.yml

migrate_vm_without_v2v:
	@$(MAKE) migrate MIGRATION_VM_FILE=$(ENVIRONMENT_DIR)/migration_vm_without_v2v.yml

migrate_vm_all:
	@status=0; \
	$(MAKE) migrate_vm_with_v2v || status=1; \
	$(MAKE) migrate_vm_without_v2v || status=1; \
	exit $$status