# OpenStack Deployment Process - Add New Nodes

Change directory to the repository root

```bash
cd /iijvn/higio-platform/openstack
```

Set the environment name for every command.

```bash
export ENV=<Name of the target env directory under environments/>
```

## Provision OPS node (applicable for Virtual Machine)

### Add new node to: `./environments/$ENV/vms_config.tfvars`

```bash
make aws_fetch_creds
```

```bash
make terraform_build TF_PROJECT=openstack_aio_provision ENV=$ENV
```

```bash
make terraform_deploy TF_PROJECT=openstack_aio_provision ENV=$ENV
```

```bash
make gen_inv ENV=$ENV
```

## OS Baseline

```bash
make os_baseline_setup ENV=$ENV TAG=dns
```

```bash
make os_baseline_setup ENV=$ENV TAG=pre_setup LIMIT=<new_node>
```

```bash
make os_baseline_setup ENV=$ENV TAG=setup LIMIT=<new_node>
```

```bash
make os_baseline_setup ENV=$ENV TAG=post_setup LIMIT=<new_node>
```

## OpenStack Configuration and Deployment

### Pre-deployment: Kolla Configuration

```bash
make kolla_config ENV=$ENV TAG=inventory
```

```bash
make kolla_config ENV=$ENV LIMIT=<new_node>
```

## Deploy new node with kolla

### Applicable for Compute/Chassis Gateway nodes

```bash
make kolla_shell ENV=$ENV ACTION=pull LIMIT=<new_node>.<domain>
```

```bash
make kolla_shell ENV=$ENV ACTION=bootstrap-servers LIMIT=<new_node>.<domain>
```

```bash
make kolla_shell ENV=$ENV ACTION=prechecks LIMIT=<new_node>.<domain>
```

```bash
make kolla_shell ENV=$ENV ACTION=deploy LIMIT=<new_node>.<domain>
```

### Applicable for Controller nodes

```bash
make kolla_shell ENV=$ENV ACTION=pull LIMIT=<new_node>.<domain>
```

```bash
make kolla_shell ENV=$ENV ACTION=bootstrap-servers LIMIT=control
```

```bash
make kolla_shell ENV=$ENV ACTION=prechecks LIMIT=<new_node>.<domain>
```

```bash
make kolla_shell ENV=$ENV ACTION=deploy LIMIT=control
```

## OpenStack Healthcheck

```bash
make ops_healthcheck ENV=$ENV TAG=healthcheck_services
```

```bash
make ops_healthcheck ENV=$ENV TAG=healthcheck_containers
```
