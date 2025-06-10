#

## Add new node

Example: add new network node

### Provision OPS network node

==> Add new node to provision config: `./environments/lab199/vms_config.tfvars`

```bash
make terraform_plan ENV=lab199 PROJECT=openstack_infras_provision

make terraform_deploy ENV=lab199 PROJECT=openstack_infras_provision
```

### Pre-setup OS for new network node

```bash
make os_setup ENV=lab199 LIMIT="ddops-gw02"
```

### Deploy new network with kolla

=> Add new node to kolla inventory: `./environments/lab199/kolla/multinode`

```bash
make kolla_addnode ENV=lab199 LIMIT="ddops-gw02"
```
