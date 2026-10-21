# V2O Migration with Red Hat os-migrate

## Directories structure

| **Path** | **Description** |
|---|---|
| `ansible/` | Ansible playbooks, roles, templates, and helper scripts for validation, setup, mapping, and deployment. |
| `docs/` | Migration tool-specific documentation, including architecture, runbooks, knowledge base (KB) articles, and troubleshooting guides. |
| `environments/` | Environment-specific variables, DNS settings, migration settings, secrets, and VM resource mappings. |
| `infra_os_migrate/` | Supporting infrastructure assets for os-migrate, including AEE build files, certificates, inventory generation, conversion setup, and migrator setup. See [Migration Infrastructure](./infra_os_migrate/README.md). |
| `output/` | Generated inventory, readiness, filtering, and migration artifact outputs. |
| `samples/` | Sample configuration files. |
| `Makefile` | Provides common commands for building, validating, configuring, and running the migration workflow. |
| `README.md` | Main documentation and usage guide for the os-migrate implementation. |
| `ansible.cfg` | Ansible configuration used by the migration playbooks. |
| `collect_vm_inventory.sh` | Collects VMware VM inventory data for use in the migration workflow. |
| `docker-compose.yml` | Defines the containerized environment used to run migration and Ansible operations. |
| `inventory.vmware_vms.yml` | VMware dynamic inventory configuration used to discover source VMs. |
| `readiness_requirements.yml` | Defines VM readiness requirements and validation criteria for migration. |

## Infrastructure Topology

(Updating...)

## Requirements

(Updating...)

## Workflow

The Red Hat os-migrate workflow consists of two main stages: preparing the migration infrastructure and performing the VM migration.

### [1. Migration Infrastructure Preparation](./docs/runbooks/guide/os_migrate_infrastructure_preparation.md)

Prepare the infrastructure and runtime required for migration.

```text
Prepare Migrator Host
        ↓
Clone Repository
        ↓
Install Dependencies
        ↓
Configure Environment
        ↓
Build AEE Runtime and Custom Patches
        ↓
Provision Conversion Host
        ↓
Validate Connectivity
```

1. Prepare an empty **Migrator Host**.
2. Clone the migration repository.
3. Install the required dependencies.
4. Define the environment variables and environment-specific configuration.
5. Build the **Ansible Execution Environment (AEE)** runtime and optionally apply custom patches to enhance migration capabilities.
6. Provision and configure the **Conversion Host**.
7. Validate connectivity to VMware, OpenStack.

### [2. VM Migration](./docs/runbooks/guide/os_migrate_vm_migration.md)

Prepare the target VMs and execute the migration.

```text
Define Resource Mapping
        ↓
Define VM List
        ↓
Collect VMware Inventory
        ↓
Validate Migration Readiness
        ↓
Generate Migration Configuration
        ↓
Execute VM Migration
```

1. Define the VMware-to-OpenStack resource mappings.
2. Define the VMware VMs to migrate.
3. Collect the VMware VM inventory.
4. Validate VM migration readiness and resource mappings.
5. Generate the migration configuration.
6. Execute the VM migration to OpenStack.

## Documentation and Runbooks

- [Migration Infrastructure Preparation](./docs/runbooks/guide/os_migrate_infrastructure_preparation.md) - Prepare the migration infrastructure and required components.

- [VM Migration Guide](./docs/runbooks/guide/os_migrate_vm_migration.md) - Prepare, validate, and migrate VMware VMs to OpenStack.

- [Knowledge Base](./docs/runbooks/kb/) - Troubleshooting guides and known issues.
