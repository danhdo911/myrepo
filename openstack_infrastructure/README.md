#

## Requirement

- Packages: docker, docker-compose

- Docker Images:
  - harbor.iij.com.vn/customized-images/ansible:2.0
  - harbor.iij.com.vn/customized-images/terraform:1.10.3
  - harbor.iij.com.vn/customized-images/ci-deploy:1.0 (run with CI pipeline)

- Clone repo with submodule:

  ```bash
  git clone --recurse-submodules https://gitlab.iij.com.vn/iijvn-randd/openstack_infrastructure.git
  ```

## Directories Structure

```bash
.
├── ansible     # logic code - submodule
├── terraform   # logic code - submodule
├── deploy
│   ├── openstack_cgw_provision     # provision openstack cgw nodes
│   └── openstack_infras_provision
├── environments
│   ├── lab199
│   │   ├── group_vars
│   │   │   └── all           # variable for setup os, kolla configs
│   │   ├── kolla
│   │   │   └── multinode     # kolla inventory
│   │   ├── dynamic_inv.ini   # dynamic ansible inventory
│   │   └── vms_config.tfvars # variable for provision management nodes
│   ├── dev
│   │   ├── ...
│   └── prod
│       └── ...
├── output
├── Makefile                  # commands to run tasks
├── docker-compose.yml
...
```

## Makefile

- Example topology: ![image](./docs/images/infras_topology.png)
- Using makefile to run deployment tasks.
  - For new deployment, please refer [new_deployment.md](./docs/new_deployment.md)
  - For add new node to exist system, please refer [add_new_node.md](./docs/add_new_node.md)

## Provision Process

![image](./docs/images/openstack_provision.png)

## CI - Management Nodes Provision Diagram

![image](./docs/images/ci-mgmtnodes-diagram.png)

## CI - Management Nodes Provision Workflow

![image](./docs/images/ci-mgmtnodes-workflow.png)
