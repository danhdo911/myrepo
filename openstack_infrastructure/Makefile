ENV ?= lab199

ROOT_DIR= ../..
DEPLOY_DIR=	deploy/$(PROJECT)
ANSIBLE_DIR= ansible
ENV_DIR=environments/$(ENV)
TF_VARS=$(ENV_DIR)/vms_config.tfvars
TF_JSON=output/$(ENV)-vms_info.json

KOLLA_VENV=/root/kolla-venv/bin
KOLLA_DIR=/etc/kolla
KOLLA_INV=$(ENV_DIR)/kolla-inventory/multinode
KOLLA_GLOBAL_YML=$(ENV_DIR)/kolla-inventory/globals.yml

######################################################################################################################
.PHONY: terraform_plan terraform_apply terraform_output clear \
		ansible_setup \
		kolla_predeploy kolla_deploy kolla_postdeploy

terraform_deploy: terraform_apply terraform_output

######################################################################################################################
terraform_plan:
	cd $(DEPLOY_DIR) && \
		terraform workspace select -or-create $(ENV) && \
		terraform fmt && terraform init && terraform validate && terraform plan -var-file=$(ROOT_DIR)/$(TF_VARS)

terraform_apply:
	cd $(DEPLOY_DIR) && \
		terraform apply -auto-approve -var-file=$(ROOT_DIR)/$(TF_VARS)

terraform_output:
	cd $(DEPLOY_DIR) && \
		terraform output -json vms_info > $(ROOT_DIR)/$(TF_JSON)

clean:
	cd $(DEPLOY_DIR) && \
		terraform destroy -auto-approve -var-file=$(ROOT_DIR)/$(TF_VARS)
		rm -f $(ROOT_DIR)/$(TF_JSON)

######################################################################################################################
ansible_setup:
	python3 ./$(ANSIBLE_DIR)/scripts/inventory.py --input-file $(TF_JSON) --output-file $(ENV_DIR)/dynamic_inv.ini
	ansible-playbook $(ANSIBLE_DIR)/playbooks/pre_setup_ops.yml \
		-i $(ENV_DIR)/dynamic_inv.ini \
		-e "vm_data_file=../$(ROOT_DIR)/$(TF_JSON)" \
		$(if $(TAG),--tags "$(TAG)",) \
		$(if $(LIMIT),--limit "$(LIMIT)",)

######################################################################################################################
# kolla:
# 	ansible-playbook $(ANSIBLE_DIR)/playbooks/kolla_ansible.yml \
# 		-i $(KOLLA_INV) \
# 		$(if $(TAG),--tags "$(TAG)",) \
# 		$(if $(LIMIT),--limit "$(LIMIT)",)

kolla_predeploy:
	. $(KOLLA_VENV)/activate
	kolla-ansible install-deps $(if $(TAG),--tags "$(TAG)",) $(if $(LIMIT),--limit "$(LIMIT)",)
	kolla-genpwd
	kolla-ansible certificates -i $(KOLLA_INV) $(if $(TAG),--tags "$(TAG)",) $(if $(LIMIT),--limit "$(LIMIT)",)
	cat /etc/kolla/certificates/ca/root.crt /etc/ssl/certs/ca-certificates.crt
	kolla-ansible bootstrap-servers -i $(KOLLA_INV) $(if $(TAG),--tags "$(TAG)",) $(if $(LIMIT),--limit "$(LIMIT)",)
	kolla-ansible precheck -i $(KOLLA_INV) $(if $(TAG),--tags "$(TAG)",) $(if $(LIMIT),--limit "$(LIMIT)",)
	deactivate

kolla_deploy:
	. $(KOLLA_VENV)/activate
	kolla-ansible deploy -i $(KOLLA_INV) $(if $(TAG),--tags "$(TAG)",) $(if $(LIMIT),--limit "$(LIMIT)",)
	deactivate

kolla_postdeploy:
	. $(KOLLA_VENV)/activate && \
		kolla-ansible post-deploy -i $(KOLLA_INV) $(if $(TAG),--tags "$(TAG)",) $(if $(LIMIT),--limit "$(LIMIT)",)
		echo "export OS_CACERT=/etc/ssl/certs/ca-certificates.crt" >> $(KOLLA_DIR)/admin-openrc.sh
		. $(KOLLA_DIR)/admin-openrc.sh
		./$(ANSIBLE_DIR)/scripts/kolla_check.sh
		deactivate


