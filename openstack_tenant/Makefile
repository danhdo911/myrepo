ENV ?= lab199
PROJECT ?= tenant_provision

ROOT_DIR= ../..
DEPLOY_DIR=	deploy/$(PROJECT)
ANSIBLE_DIR= ansible
ENV_DIR=environments/$(ENV)
TF_VARS=$(ENV_DIR)/vms_config.tfvars
TF_JSON=output/$(ENV)-vms_info.json

KOLLA_VENV=/root/kolla-venv/bin
KOLLA_DIR=/etc/kolla
KOLLA_INV=$(ENV_DIR)/kolla/multinode

######################################################################################################################

### CHECK TERRAFORM & ANSIBLE MODULES ################################################################################
# REPO_URL ?= https://gitlab.iij.com.vn/iijvn-randd/
# REPO_ANSIBLE=openstack_ansible
# REPO_TERRAFORM=terraform_vsphere

# .PHONY: check_submodule

# check_submodule:
# 	docker compose -f docker-compose.yml run --rm terraform "\
# 		./submodule_check.sh $(REPO_ANSIBLE) ansible && \
# 		./submodule_check.sh $(REPO_TERRAFORM) terraform"
		
### TERRAFORM PROVISIONING OPENSTACK INFRASTRUCTURE (GS) #############################################################
.PHONY: terraform_deploy terraform_plan terraform_apply terraform_output terraform_clean

terraform_deploy: terraform_apply terraform_output

#===================== Executions =====================#
terraform_plan:
	docker compose -f docker-compose.yml run --rm terraform "\
		cd $(DEPLOY_DIR) && \
			terraform workspace select -or-create $(ENV) && \
			terraform fmt && terraform init && terraform validate && terraform plan -var-file=$(ROOT_DIR)/$(TF_VARS)"

terraform_apply:
	docker compose -f docker-compose.yml run --rm terraform "\
		cd $(DEPLOY_DIR) && \
			terraform apply -auto-approve -var-file=$(ROOT_DIR)/$(TF_VARS)"

terraform_output:
	docker compose -f docker-compose.yml run --rm terraform "\
		cd $(DEPLOY_DIR) && \
			terraform output -json vms_info > $(ROOT_DIR)/$(TF_JSON)"

terraform_clean:
	docker compose -f docker-compose.yml run --rm terraform "\
		cd $(DEPLOY_DIR) && \
			terraform workspace select $(ENV) && \
			terraform destroy -var-file=$(ROOT_DIR)/$(TF_VARS) && \
			rm -f $(ROOT_DIR)/$(TF_JSON)"
