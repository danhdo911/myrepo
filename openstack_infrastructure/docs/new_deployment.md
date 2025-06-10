#

## New deployment

### Provision OPS Mangement node (VM)

==> Declare variables to provision management nodes: `./environments/lab199/vms_config.tfvars`

```bash
make terraform_plan ENV=lab199 PROJECT=openstack_infras_provision

make terraform_deploy ENV=lab199 PROJECT=openstack_infras_provision
```

### Pre-setup OS and generate kolla config files

```bash
make os_setup ENV=lab199

make gen_config ENV=lab199
```

### Deploy OPS with kolla

=> Declare kolla inventory: `./environments/lab199/kolla/multinode`

```bash
make kolla_deps ENV=lab199

make kolla_pre ENV=lab199

make kolla_deploy ENV=lab199

make kolla_post ENV=lab199
```
