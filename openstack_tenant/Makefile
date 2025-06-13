ENV ?= HCM
TENANT ?= tenant_A
PROJECT ?= tenant_provision

ROOT_DIR= ../..
DEPLOY_DIR=	deploy/$(PROJECT)
ENV_DIR=environments/$(ENV)/$(TENANT)
TF_VARS=$(ENV_DIR)/$(VAR_FILE)

TERRAFORM_DIR=./terraform
SCRIPT=$(TERRAFORM_DIR)/scripts/ops/ops_generate_tf.py
TEMPLATE_DIR=$(TERRAFORM_DIR)/templates/ops
DATA_DIR=$(ENV_DIR)/csv_data


# TF_JSON=output/$(ENV)-vms_info.json
# ANSIBLE_DIR= ansible
# KOLLA_VENV=/root/kolla-venv/bin
# KOLLA_DIR=/etc/kolla
# KOLLA_INV=$(ENV_DIR)/kolla/multinode

######################################################################################################################

### GENERATE TENANT CONFIGURATIONS ###################################################################################
.PHONY: config

config:
	@echo "==>> Generating Tenant Configuration..."
	python3 $(SCRIPT) --template_dir $(TEMPLATE_DIR) --data_dir $(DATA_DIR) --output_file $(DEPLOY_DIR)/main.tf 

### TERRAFORM PROVISIONING OPENSTACK INFRASTRUCTURE (GS) #############################################################
.PHONY: terraform_deploy terraform_plan terraform_apply terraform_output terraform_clean

terraform_deploy: terraform_apply terraform_output

#===================== Executions =====================#
terraform_plan:
	docker compose -f docker-compose.yml run --rm terraform "\
		cd $(DEPLOY_DIR) && \
			terraform workspace select -or-create $(ENV)_$(TENANT) && \
			terraform fmt && terraform init && terraform validate && terraform plan -var-file=$(ROOT_DIR)/$(TF_VARS)"

terraform_apply:
	docker compose -f docker-compose.yml run --rm terraform "\
		cd $(DEPLOY_DIR) && \
			terraform apply -auto-approve -var-file=$(ROOT_DIR)/$(TF_VARS)"

# terraform_output:
# 	docker compose -f docker-compose.yml run --rm terraform "\
# 		cd $(DEPLOY_DIR) && \
# 			terraform output -json vms_info > $(ROOT_DIR)/$(TF_JSON)"

terraform_clean:
	docker compose -f docker-compose.yml run --rm terraform "\
		cd $(DEPLOY_DIR) && \
			terraform workspace select $(ENV)_$(TENANT) && \
			terraform destroy -var-file=$(ROOT_DIR)/$(TF_VARS)"