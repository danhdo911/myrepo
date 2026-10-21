### Include .env #############################################################
ifneq ($(wildcard .env),)
include .env
endif

### LOCAL VARIABLES #############################################################
ENV ?= lab199
ROOT_DIR ?= $(WORK_DIR)
ENV_DIR = environments/$(ENV)
OUTPUT = output

VAULT_FIELD = ansible_private_key
VAULT_SECRET_PATH = $(TF_VAR_vault_secret_path)/$(TF_VAR_vault_secret_data)

ANSIBLE_DIR = ansible
ANSIBLE_INV = $(ROOT_DIR)/$(ENV_DIR)/ansible/inventory.ini
ANSIBLE_PRIVATE_KEY = ansible_private_key

TF_PROJECT ?= $(TF_PROJECT)
TF_DIR = deploy/$(TF_PROJECT)
TF_VARS = $(ENV_DIR)/terraform/vms_config.tfvars
TF_PLAN = $(ROOT_DIR)/$(OUTPUT)/plan.tfplan
TF_JSON = $(ROOT_DIR)/$(OUTPUT)/$(ENV)_vms_info.json

KOLLA_VENV = os-venv
KOLLA_DIR = /etc/kolla
KOLLA_WORKDIR_DEFAULT = /root/workdir
KOLLA_WORKDIR_OPENSTACK = $(KOLLA_WORKDIR_DEFAULT)/openstack
KOLLA_INVENTORY = $(KOLLA_WORKDIR_OPENSTACK)/multinode
VIRTUAL_ENV = $(KOLLA_WORKDIR_OPENSTACK)/$(KOLLA_VENV)/bin/activate

DOCKER_IMAGES := \
	$(HARBOR_REGISTRY)/customized-images/ansible:4.0 \
	$(HARBOR_REGISTRY)/customized-images/terraform:1.10.3

### PREPARE DEPLOYMENT HOST #############################################################
.PHONY: docker_login docker_pull vault_get_sshkey

docker_login:
	@echo "Logging in to $(HARBOR_REGISTRY)"
	@echo "$(HARBOR_PASSWORD)" | docker login "$(HARBOR_REGISTRY)" \
		-u "$(HARBOR_USER)" \
		--password-stdin

docker_pull: docker_login
	@for image in $(DOCKER_IMAGES); do \
		if docker image inspect "$$image" >/dev/null 2>&1; then \
			echo "Image already exists: $$image"; \
		else \
			echo "Pulling $$image"; \
			docker pull "$$image"; \
		fi; \
	done

vault_get_sshkey:
	@echo "Retrieving the SSH key for the Ansible host from the $(VAULT_ADDR)"
	@printf '%s\n' "$$(VAULT_ADDR=$(VAULT_ADDR) VAULT_TOKEN=$(VAULT_TOKEN) \
		vault kv get -field="$(VAULT_FIELD)" "$(VAULT_SECRET_PATH)")" > "$(ANSIBLE_PRIVATE_KEY)"
	@chmod 600 "$(ANSIBLE_PRIVATE_KEY)"
	@echo "SSH key saved to $(ANSIBLE_PRIVATE_KEY)"

### AWS S3 FOR TERRAFORM STATE #############################################################
.PHONY: aws_fetch_creds

aws_fetch_creds:
	docker compose -f docker-compose.yml run --rm terraform "\
		/bin/sh update_aws_credentials.sh \
	"

### TERRAFORM PROVISIONING OPENSTACK INFRASTRUCTURE #############################################################
.PHONY: terraform_init terraform_plan terraform_apply terraform_output terraform_clean \
		terraform_build terraform_deploy

terraform_build: terraform_init terraform_plan
terraform_deploy: terraform_apply terraform_output

#===================== Executions =====================#
terraform_init:
	docker compose -f docker-compose.yml run --rm terraform "\
		cd $(TF_DIR) \
			&& terraform fmt \
			&& terraform init -reconfigure \
			&& terraform validate \
	"

terraform_plan:
	docker compose -f docker-compose.yml run --rm terraform "\
		cd $(TF_DIR) \
			&& terraform workspace select -or-create $(ENV) \
			&& terraform plan -input=false -var-file=$(ROOT_DIR)/$(TF_VARS) -out=$(TF_PLAN) \
	"

terraform_apply:
	docker compose -f docker-compose.yml run --rm terraform "\
		cd $(TF_DIR) \
			&& terraform workspace select $(ENV) \
			&& terraform apply -input=false $(TF_PLAN) \
	"

terraform_output:
	docker compose -f docker-compose.yml run --rm terraform "\
		cd $(TF_DIR) \
			&& terraform workspace select $(ENV) \
			&& terraform output -json vms_info > $(TF_JSON) \
	"

terraform_clean:
	docker compose -f docker-compose.yml run --rm terraform "\
		cd $(TF_DIR) \
			&& terraform workspace select $(ENV) \
			&& terraform destroy -auto-approve -var-file=$(ROOT_DIR)/$(TF_VARS) \
			&& rm -f $(TF_JSON) \
	"

### ANSIBLE PREPARE FOR SETUP OPENSTACK ################################################################################
.PHONY: gen_inv os_baseline_setup kolla_setup

#===================== Executions =====================#
gen_inv:
	docker compose -f docker-compose.yml run --rm ansible_ops "\
		python3 ./$(ANSIBLE_DIR)/scripts/render_inventory/inventory.py \
			--input-file $(TF_JSON) \
			--template-file ./$(ANSIBLE_DIR)/scripts/render_inventory/inventory.j2 \
			--output-file $(ANSIBLE_INV) \
	"

os_extend_disk:
	docker compose -f docker-compose.yml run --rm ansible_ops "\
		ansible-playbook $(ANSIBLE_DIR)/playbooks/os_extend_disk.yml \
			-i $(ANSIBLE_INV) \
			$(if $(TAG),--tags "$(TAG)",) \
			$(if $(LIMIT),--limit "$(LIMIT)",) \
			-v \
	"

os_baseline_setup:
	docker compose -f docker-compose.yml run --rm ansible_ops "\
		ansible-playbook $(ANSIBLE_DIR)/playbooks/os_baseline_setup.yml \
			-i $(ANSIBLE_INV) \
			-e "vm_data_file=$(TF_JSON)" \
			$(if $(TAG),--tags "$(TAG)",) \
			$(if $(LIMIT),--limit "$(LIMIT)",) \
			-v \
	"

kolla_config:
	docker compose -f docker-compose.yml run --rm ansible_ops "\
		ansible-playbook $(ANSIBLE_DIR)/playbooks/kolla_config.yml \
			-i $(ANSIBLE_INV) -v \
			$(if $(TAG),--tags "$(TAG)",) \
			$(if $(LIMIT),--limit "$(LIMIT)",) \
			-v \
	"

### OPENSTACK DEPLOYMENT ################################################################################
SSH_USER ?= root
SSH_KEY ?= $(ROOT_DIR)/ansible_private_key
SSH_OPTS ?= -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

.PHONY: kolla_shell kolla_addcert kolla_verify \
		kolla_patch \
		ops_postdeploy

kolla_shell:
	@docker compose -f docker-compose.yml run --rm ansible_ops "\
		INFRA_HOST=\$$(ansible-inventory -i $(ANSIBLE_INV) --list | jq -r '.infra.hosts[0]'); \
		INFRA_IP=\$$(ansible-inventory -i $(ANSIBLE_INV) --host \$${INFRA_HOST} | jq -r '.ansible_host'); \
		ssh -tt -i $(SSH_KEY) $(SSH_OPTS) $(SSH_USER)@\$${INFRA_IP} '\
			source $(VIRTUAL_ENV) && \
				kolla-ansible $(ACTION) -i $(KOLLA_INVENTORY) \
				$(if $(TAG),--tags "$(TAG)",) \
				$(if $(LIMIT),--limit "$(LIMIT)",) && \
			deactivate \
		' \
	"

kolla_patch:
	docker compose -f docker-compose.yml run --rm ansible_ops "\
		ansible-playbook $(ANSIBLE_DIR)/playbooks/kolla_patch.yml \
			-i $(ANSIBLE_INV) \
			$(if $(TAG),--tags "$(TAG)",) \
			$(if $(LIMIT),--limit "$(LIMIT)",) \
			-v \
	"

ops_postdeploy:
	docker compose -f docker-compose.yml run --rm ansible_ops "\
		ansible-playbook $(ANSIBLE_DIR)/playbooks/ops_postdeploy.yml \
			-i $(ANSIBLE_INV) \
			$(if $(TAG),--tags "$(TAG)",) \
			$(if $(LIMIT),--limit "$(LIMIT)",) \
			-v \
	"

ops_healthcheck:
	docker compose -f docker-compose.yml run --rm ansible_ops "\
		ansible-playbook $(ANSIBLE_DIR)/playbooks/ops_healthcheck.yml \
			-i $(ANSIBLE_INV) \
			$(if $(TAG),--tags "$(TAG)",) \
			$(if $(LIMIT),--limit "$(LIMIT)",) \
			-v \
	"
# ### KOLLA OPENSTACK DEPLOYMENT ################################################################################
# .PHONY: kolla_ansible

# kolla_ansible:
# 	docker compose -f docker-compose.yml run --rm ansible "\
# 		ansible-playbook $(ANSIBLE_DIR)/playbooks/openstack_postdeploy.yml \
# 			-i $(ANSIBLE_INV) \
# 			$(if $(TAG),--tags "$(TAG)",) \
# 			$(if $(LIMIT),--limit "$(LIMIT)",) \
# 			-v \
# 			"

#===================#
#=== Old version ===#
#===================#
# gen_config: ## globals, cinder nfs, neutron ml2_config
# 	docker compose -f docker-compose.yml run --rm ansible_kolla "\
# 		ansible-playbook $(ANSIBLE_DIR)/playbooks/pre/generate_config_files.yml \
# 			-i $(ANSIBLE_INV) \
# 			-e "kolla_default_dir=$(KOLLA_DIR)/" \
# 			$(if $(TAG),--tags "$(TAG)",) \
# 			-v \
# 			"

# ### KOLLA OPENSTACK ###################################################################################################################
# .PHONY: kolla_deps kolla_pre kolla_post kolla_add_node \
# 		kolla_install_deps kolla_genpwd kolla_pull kolla_certificates kolla_bootstrap kolla_precheck \
# 		kolla_deploy kolla_postdeploy kolla_addcert kolla_verify \
# 		kolla_reconfigure

# # Using for new provision
# kolla_deps: kolla_install_deps kolla_genpwd
# kolla_pre: kolla_certificates kolla_bootstrap kolla_precheck
# kolla_post: kolla_postdeploy kolla_addcert kolla_verify

# # Using for add new node - run with LIMIT SUBSET
# kolla_addnode: kolla_bootstrap kolla_precheck kolla_deploy kolla_postdeploy kolla_verify

# #===================== Executions =====================#
# kolla_install_deps:
# 	. $(KOLLA_VENV)/activate && \
# 		kolla-ansible install-deps && \
# 		deactivate

# kolla_genpwd:
# 	. $(KOLLA_VENV)/activate && \
# 		kolla-genpwd && \
# 		deactivate

# kolla_certificates:
# 	. $(KOLLA_VENV)/activate && \
# 		kolla-ansible certificates -i $(KOLLA_INV) $(if $(TAG),--tags "$(TAG)",) $(if $(LIMIT),--limit "$(LIMIT)",) && \
# 		deactivate

# kolla_bootstrap:
# 	. $(KOLLA_VENV)/activate && \
# 		kolla-ansible bootstrap-servers -i $(KOLLA_INV) $(if $(TAG),--tags "$(TAG)",) $(if $(LIMIT),--limit "$(LIMIT)",) && \
# 		deactivate
	
# kolla_precheck:
# 	. $(KOLLA_VENV)/activate && \
# 		kolla-ansible prechecks -i $(KOLLA_INV) $(if $(TAG),--tags "$(TAG)",) $(if $(LIMIT),--limit "$(LIMIT)",) && \
# 		deactivate

# kolla_deploy:
# 	. $(KOLLA_VENV)/activate && \
# 		kolla-ansible deploy -i $(KOLLA_INV) $(if $(TAG),--tags "$(TAG)",) $(if $(LIMIT),--limit "$(LIMIT)",) && \
# 		deactivate

# kolla_postdeploy:
# 	. $(KOLLA_VENV)/activate && \
# 		kolla-ansible post-deploy -i $(KOLLA_INV) $(if $(TAG),--tags "$(TAG)",) $(if $(LIMIT),--limit "$(LIMIT)",) && \
# 		deactivate

# kolla_addcert:
# 	cat /etc/kolla/certificates/ca/root.crt | sudo tee -a /etc/ssl/certs/ca-certificates.crt
# 	echo "export OS_CACERT=/etc/ssl/certs/ca-certificates.crt" >> $(KOLLA_DIR)/admin-openrc.sh

# kolla_verify:
# 	. $(KOLLA_VENV)/activate && \
# 		. $(KOLLA_DIR)/admin-openrc.sh && \
# 		./$(ANSIBLE_DIR)/scripts/kolla_check.sh && \
# 		deactivate

# kolla_reconfigure:
# 	. $(KOLLA_VENV)/activate && \
# 		kolla-ansible reconfigure -i $(KOLLA_INV) $(if $(TAG),--tags "$(TAG)",) $(if $(LIMIT),--limit "$(LIMIT)",) && \
# 		deactivate
