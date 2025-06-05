#

## Structure

```bash
openstack_infrastructure/
├── makefile
├── environments/
│   ├── dev/
│   │   ├── terraform.tfvars
│   │   ├── globals.yml.j2
│   │   └── kolla-inventory
│   │       └── multinode
│   ├── staging/
│   │   └── ...
│   └── prod/
│       └── ...
├── output/                        # Terraform outputs
│   └── dev-vms_info.json
├── terraform-openstack/           # Terraform module
├── ansible-openstack/             # Ansible playbooks

```
