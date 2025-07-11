### Include .env #############################################################
ifneq ($(wildcard .env),)
include .env
endif

### LOCAL VARIABLES #############################################################

ENV ?= lab199
ROOT_DIR ?= $(WORK_DIR)
TF_PROJECT ?= $(TF_PROJECT)

ANSIBLE_DIR= ansible
ENV_DIR=environments/$(ENV)

TERRAFORM_DIR = deploy/$(TF_PROJECT)
TF_VARS=$(ENV_DIR)/vms_config.tfvars
TF_PLAN=plan.tfplan
TF_JSON=output/$(ENV)-vms_info.json

KOLLA_VENV=/root/kolla-venv/bin
KOLLA_DIR=/etc/kolla
KOLLA_INV=$(ENV_DIR)/kolla/multinode

.PHONY: aws_fetch_creds

aws_fetch_creds:
	docker compose -f docker-compose.yml run --rm terraform "\
		/bin/sh update_aws_credentials.sh"

### TERRAFORM PROVISIONING OPENSTACK INFRASTRUCTURE (GS) #############################################################
.PHONY: terraform_init terraform_plan terraform_apply terraform_output terraform_clean \
		terraform_build terraform_deploy

terraform_build: terraform_init terraform_plan
terraform_deploy: terraform_apply terraform_output

#===================== Executions =====================#
terraform_init:
	docker compose -f docker-compose.yml run --rm terraform "\
		cd $(TERRAFORM_DIR) \
			&& terraform fmt \
			&& terraform init -reconfigure \
			&& terraform validate"

terraform_plan:
	docker compose -f docker-compose.yml run --rm terraform "\
		cd $(TERRAFORM_DIR) \
			&& terraform workspace select -or-create $(ENV) \
			&& terraform plan -input=false -var-file=$(ROOT_DIR)/$(TF_VARS) -out=$(TF_PLAN)"

terraform_apply:
	docker compose -f docker-compose.yml run --rm terraform "\
		cd $(TERRAFORM_DIR) \
			&& terraform workspace select $(ENV) \
			&& terraform apply -input=false $(TF_PLAN)"

terraform_output:
	docker compose -f docker-compose.yml run --rm terraform "\
		cd $(TERRAFORM_DIR) \
			&& terraform workspace select $(ENV) \
			&& terraform output -json vms_info > $(ROOT_DIR)/$(TF_JSON)"

terraform_clean:
	docker compose -f docker-compose.yml run --rm terraform "\
		cd $(TERRAFORM_DIR) \
			&& terraform workspace select $(ENV) \
			&& terraform destroy -auto-approve -var-file=$(ROOT_DIR)/$(TF_VARS) \
			&& rm -f $(ROOT_DIR)/$(TF_JSON)"

### ANSIBLE PREPARE FOR SETUP OPENSTACK ################################################################################
.PHONY: gen_inv os_setup gen_config

#===================== Executions =====================#
gen_inv:
	docker compose -f docker-compose.yml run --rm ansible "\
		python3 ./$(ANSIBLE_DIR)/scripts/inventory.py \
			--input-file $(TF_JSON) \
			--template-file ./$(ANSIBLE_DIR)/templates/inventory.j2 \
			--output-file $(ENV_DIR)/dynamic_inv.ini"

os_setup:
	docker compose -f docker-compose.yml run --rm ansible "\
		ansible-playbook $(ANSIBLE_DIR)/playbooks/pre_setup_ops.yml \
			-i $(ENV_DIR)/dynamic_inv.ini \
			-e "vm_data_file=$(ROOT_DIR)/$(TF_JSON)" \
			$(if $(TAG),--tags "$(TAG)",) \
			$(if $(LIMIT),--limit "$(LIMIT)",)"

gen_config: ## globals, cinder nfs, neutron ml2_config
	docker compose -f docker-compose.yml run --rm ansible "\
		ansible-playbook $(ANSIBLE_DIR)/playbooks/pre/generate_config_files.yml \
			-i $(ENV_DIR)/dynamic_inv.ini \
			-e "kolla_default_dir=$(KOLLA_DIR)/" \
			$(if $(TAG),--tags "$(TAG)",)"

### KOLLA OPENSTACK ###################################################################################################################
.PHONY: kolla_deps kolla_pre kolla_post kolla_add_node \
		kolla_install_deps kolla_genpwd kolla_certificates kolla_bootstrap kolla_precheck \
		kolla_deploy kolla_postdeploy kolla_addcert kolla_verify \
		kolla_reconfigure

# Using for new provision
kolla_deps: kolla_install_deps kolla_genpwd
kolla_pre: kolla_certificates kolla_bootstrap kolla_precheck
kolla_post: kolla_postdeploy kolla_addcert kolla_verify

# Using for add new node - run with LIMIT SUBSET
kolla_addnode: kolla_bootstrap kolla_precheck kolla_deploy kolla_postdeploy kolla_verify

#===================== Executions =====================#
kolla_install_deps:
	. $(KOLLA_VENV)/activate && \
		kolla-ansible install-deps && \
		deactivate

kolla_genpwd:
	. $(KOLLA_VENV)/activate && \
		kolla-genpwd && \
		deactivate

kolla_certificates:
	. $(KOLLA_VENV)/activate && \
		kolla-ansible certificates -i $(KOLLA_INV) $(if $(TAG),--tags "$(TAG)",) $(if $(LIMIT),--limit "$(LIMIT)",) && \
		deactivate

kolla_bootstrap:
	. $(KOLLA_VENV)/activate && \
		kolla-ansible bootstrap-servers -i $(KOLLA_INV) $(if $(TAG),--tags "$(TAG)",) $(if $(LIMIT),--limit "$(LIMIT)",) && \
		deactivate
	
kolla_precheck:
	. $(KOLLA_VENV)/activate && \
		kolla-ansible precheck -i $(KOLLA_INV) $(if $(TAG),--tags "$(TAG)",) $(if $(LIMIT),--limit "$(LIMIT)",) && \
		deactivate

kolla_deploy:
	. $(KOLLA_VENV)/activate && \
		kolla-ansible deploy -i $(KOLLA_INV) $(if $(TAG),--tags "$(TAG)",) $(if $(LIMIT),--limit "$(LIMIT)",) && \
		deactivate

kolla_postdeploy:
	. $(KOLLA_VENV)/activate && \
		kolla-ansible post-deploy -i $(KOLLA_INV) $(if $(TAG),--tags "$(TAG)",) $(if $(LIMIT),--limit "$(LIMIT)",)

kolla_addcert:
	cat /etc/kolla/certificates/ca/root.crt /etc/ssl/certs/ca-certificates.crt
	echo "export OS_CACERT=/etc/ssl/certs/ca-certificates.crt" >> $(KOLLA_DIR)/admin-openrc.sh

kolla_verify:
	. $(KOLLA_VENV)/activate && \
		. $(KOLLA_DIR)/admin-openrc.sh && \
		./$(ANSIBLE_DIR)/scripts/kolla_check.sh && \
		deactivate

kolla_reconfigure:
	. $(KOLLA_VENV)/activate && \
		kolla-ansible reconfigure -i $(KOLLA_INV) $(if $(TAG),--tags "$(TAG)",) $(if $(LIMIT),--limit "$(LIMIT)",) && \
		deactivate

