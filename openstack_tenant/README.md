# Openstack Tenant Provision

## Requirement

- Install packages:
  - docker
  - docker-compose

- Clone repo with submodule:

  ```bash
  git clone --recurse-submodules https://gitlab.iij.com.vn/iijvn-randd/openstack_tenant.git
  ```

- VAULT_TOKEN to access HashiVault

## Structure

```bash
.
├── terraform                   # logic code
├── deploy
│   └── tenant_provision        # provision tenant project
├── environments
│   ├── HCM
│   │   ├── tenant_A
│   │   │   ├── csv_data
│   │   │   │   ├── network.csv
│   │   │   │   ├── project.csv
│   │   │   │   └── router.csv
│   │   │   └── tenant_a.tfvars
│   │   ├── tenant_B
│   │   │   ├── csv_data
│   │   │   └── tenant_b.tfvars
│   │   └── ...
│   └── HNI
│       └── ...
├── Makefile                    # commands to run tasks
├── docker-compose.yml
└── .env
...
```

## Makefile

==> Declare variables to provision tenant project:

- `./environments/HCM/tenant_A/tenant_a.tfvars`
- `./environments/HCM/tenant_A/csv_data/*`
- create `./.env` file with `VAULT_TOKEN="xyz"`

==> Execute to provision:

```bash
# Generate project configurations for tenant according to csv files
make config

# Run terraform init, validate and plan
make terraform_plan VAR_FILE=tenant_a.tfvars

# Run terraform apply
make terraform_apply VAR_FILE=tenant_a.tfvars
```

## Process

- Create project, admin user, assgin role, set quotas.
- Create provider network, allocate ip pool.
- Create router, assign external gateway.
