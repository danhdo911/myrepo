ENV ?= lab199

ROOT_DIR= ..
SCRIPT=scripts

TERRAFORM_DIR=terraform
ENV_DIR=environments/$(ENV)
TF_VARS=$(ENV_DIR)/$(ENV).tfvars
TF_JSON=output/vms_info.json

ANSIBLE_DIR=ansible
INVENTORY=./$(ANSIBLE_DIR)/inventory/dynamic_inv.ini


######################################################################################################################

### TERRAFORM PROVISIONING OPENSTACK INFRASTRUCTURE (GS) #############################################################
.PHONY: terraform_deploy terraform_plan terraform_apply terraform_output terraform_clean

terraform_deploy: terraform_apply terraform_output

#===================== Executions =====================#
terraform_plan:
	docker compose -f docker-compose.yml run --rm terraform "\
		cd $(TERRAFORM_DIR) && \
			terraform workspace select -or-create $(ENV) && \
			terraform fmt && terraform init && terraform validate && terraform plan -var-file=$(TF_VARS)"

terraform_apply:
	docker compose -f docker-compose.yml run --rm terraform "\
		cd $(TERRAFORM_DIR) && \
			terraform apply -auto-approve -var-file=$(TF_VARS)"

terraform_output:
	docker compose -f docker-compose.yml run --rm terraform "\
		cd $(TERRAFORM_DIR) && \
			terraform output -json vms_info > $(ROOT_DIR)/$(TF_JSON)"

terraform_clean:
	docker compose -f docker-compose.yml run --rm terraform "\
		cd $(TERRAFORM_DIR) && \
			terraform workspace select $(ENV) && \
			terraform destroy -var-file=$(TF_VARS)"

### ANSIBLE PREPARE FOR SETUP OPENSTACK ################################################################################
.PHONY: inventory deploy

#===================== Executions =====================#
inventory:
	docker compose -f docker-compose.yml run --rm ansible "\
		python3 $(SCRIPT)/inventory.py \
			--input-file $(TF_JSON) \
			--template-file ./$(ANSIBLE_DIR)/templates/inventory.j2 \
			--output-file $(INVENTORY)"

proxy_config:
	docker compose -f docker-compose.yml run --rm ansible "\
		python3 $(SCRIPT)/inventory.py \
			--input-file $(TF_JSON) \
			--template-file ./$(ANSIBLE_DIR)/templates/haproxy.cfg.j2 \
			--output-file ./$(ANSIBLE_DIR)/roles/haproxy/templates/haproxy.cfg.j2"

deploy:
	docker compose -f docker-compose.yml run --rm ansible "\
		ansible-playbook ./$(ANSIBLE_DIR)/deploy.yml \
			-i $(INVENTORY) \
			$(if $(TAG),--tags "$(TAG)",) \
			$(if $(LIMIT),--limit "$(LIMIT)",)"