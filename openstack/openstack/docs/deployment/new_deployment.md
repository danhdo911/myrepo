# OpenStack Deployment Process - New

> **NOTE:**
>
> - Run commands from the repository root.
> - Update the `ENV` parameter according to your target environment.

> **NOTE:**
>
> - Terraform state are stored in AWS S3 as backend.
> - In Test/LAB environment, please store terraform state in local by remove `deploy/openstack_aio_provision/backend.tf`
>

Change directory to the repository root

```bash
cd /iijvn/higio-platform/openstack
```

Set the environment name for every command.

```bash
export ENV=<Name of the target env directory under environments/>
```

Copy the sample_environment and update the variables.

```bash
rsync -av --delete samples/sample_environment/ environments/$ENV/
```

## Provision Mangement nodes - Virtual Machine

### Declare variables

- `./environments/$ENV/vms_config.tfvars`

### Fetch AWS Credentials

Run this only when Terraform state uses AWS S3 and MFA/session credentials are required.

```bash
make aws_fetch_creds
```

### Provision Infrastructure With Terraform

```bash
make terraform_build TF_PROJECT=openstack_aio_provision ENV=$ENV
```

```bash
make terraform_deploy TF_PROJECT=openstack_aio_provision ENV=$ENV
```

Expected output:

```text
output/$ENV_vms_info.json
```

### Generate Ansible Inventory

```bash
make gen_inv ENV=$ENV
```

## Extend Ubuntu LVM disk (applicable for VM)

Extend the root disk using the following layout:

- Root disk partition: `/dev/sda3`
- Logical volume (LV): `ubuntu-lv`
- Volume group (VG):  `ubuntu-vg`

```bash
make os_extend_disk ENV=$ENV
```

## OS Baseline

### Declare variables

- General configurations: `./environments/$ENV/ansible/group_vars/os_baseline/main.yml`

- Declare interface_extra_routes (if any): `./environments/$ENV/ansiblegroup_vars/<control|network|compute|infra>/routes.yml`

### Run the OS baseline in phases

```bash
make os_baseline_setup ENV=$ENV TAG=pre_setup
```

```bash
make os_baseline_setup ENV=$ENV TAG=setup
```

```bash
make os_baseline_setup ENV=$ENV TAG=post_setup
```

## OpenStack Core Services Configuration and Deployment

### Declare variables

- `./environments/$ENV/ansible/group_vars/kolla_config/*`

### Pre-deployment: Kolla Configuration

Initialize Kolla-Ansible:

```bash
make kolla_config ENV=$ENV TAG=kolla_init
```

Generate globals and core service configuration:

```bash
make kolla_config ENV=$ENV TAG=globals_config,kolla_core_services
```

### Deployment OpenStack with Kolla-Ansible

Run Kolla actions from the deployment host through the infra node.

```bash
make kolla_shell ENV=$ENV ACTION=pull
```

```bash
make kolla_shell ENV=$ENV ACTION=certificates
```

```bash
make kolla_shell ENV=$ENV ACTION=bootstrap-servers
```

```bash
make kolla_shell ENV=$ENV ACTION=prechecks
```

```bash
make kolla_shell ENV=$ENV ACTION=deploy
```

```bash
make kolla_shell ENV=$ENV ACTION=post-deploy
```

### Post-deployment: OpenStack Configuration

Fetch OpenStack auth artifacts and configure CA:

```bash
make ops_postdeploy ENV=$ENV TAG=ops_auth_fetch,addcerts
```

Run OpenStack Healthcheck:

```bash
make ops_healthcheck ENV=$ENV TAG=healthcheck_services
```

```bash
make ops_healthcheck ENV=$ENV TAG=healthcheck_containers
```

#### Flavors Template

```bash
make ops_postdeploy ENV=$ENV TAG=flavors
```

#### Qos Volumes

Enable QoS Volumes at `./environments/$ENV/ansible/group_vars/kolla_config/post_deploy.yml`.

```bash
qos_volume_enabled: true
```

Generate configurations.

```bash
make ops_postdeploy ENV=$ENV TAG=qos_volume
```

Run task to set `default_volume_type` parameter in `/etc/kolla/config/cinder.conf`.

```bash
make kolla_config ENV=$ENV TAG=cinder
```

Reconfigure OpenStack services.

```bash
make kolla_shell ENV=$ENV ACTION=reconfigure TAG=cinder
```

## After deployment

- [Patching for OpenStack 2025.1](./patch_2025.1/patch_2025v1.md).
- [Integrating OpenStack services](./integrate_openstack_services.md).
- [Additional OpenStack nodes](./add_new_node.md).

---
