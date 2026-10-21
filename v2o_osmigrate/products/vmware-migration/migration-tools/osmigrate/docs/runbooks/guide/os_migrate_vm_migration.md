# Red Hat os-migrate VM Migration Guide

This guide describes the process for preparing and migrating VMware virtual machines to OpenStack using Red Hat os-migrate.

Change to the os-migrate tool directory:

```bash
cd /iijvn/p2op-vn/products/vmware-migration/migration-tools/osmigrate
```

Set the target environment name before running the migration commands:

```bash
export ENV=<TARGET_ENVIRONMENT>
```

`<TARGET_ENVIRONMENT>` must match the name of the target environment directory under `environments/`.

## 1. Configure VM Resource Mapping

Update the VM resource mapping configuration to define how VMware resources are mapped to OpenStack resources.

The configuration includes:

- **Cinder volume type mapping**: Defines the default Cinder volume type used for migrated VM disks.
- **Security group mapping**: Defines the default OpenStack security group assigned to migrated VMs.
- **Network mapping**: Maps each VMware port group ID to its corresponding OpenStack network and subnet.

Edit the resource mapping file:

```bash
nano ./environments/$ENV/vm_resources_mapping.yml
```

Configure the required mappings:

```yaml
### Default Cinder Volume Type
cinder_volume_type: "<cinder_volume_type>"  # e.g., oso-default-4k

### Default Security Group
security_groups: "<security_group_id>"  # e.g., 67033f4a-f8b9-464d-a8ea-xxxx

### Network Mapping from VMware to OpenStack
network_mappings:
  <vmware_portgroup_id_01>:  # e.g., dvportgroup-xxx
    ops_network_name: "<openstack_network_name_01>"
    ops_network_id: "<openstack_network_id_01>"
    ops_subnet_id: "<openstack_subnet_id_01>"

  <vmware_portgroup_id_xyz>:
    ops_network_name: "<openstack_network_name_xyz>"
    ops_network_id: "<openstack_network_id_xyz>"
    ops_subnet_id: "<openstack_subnet_id_xyz>"
```

Ensure all VMware port groups used by the VMs being migrated have a corresponding OpenStack network mapping.

## 2. Define VMs for Migration

Define the VM or list of VMs to migrate using their VMware virtual machine names.

The VMware inventory plugin uses `filter_expressions` to determine which VMs are included in the collected inventory.

[!NOTE]
Only update the filter_expressions parameter to define the VMs for migration. Keep the other inventory parameters unchanged.

Edit the VMware inventory configuration:

```bash
nano ./inventory.vmware_vms.yml
```

Example configuration:

```yaml
---
plugin: vmware.vmware.vms

validate_certs: false

search_paths:
  - ${VMWARE_SEARCH_PATH}  # Refer to VMWARE_SEARCH_PATH in the .env file

properties: [config, guest]

hostnames:
  - config.name

# Notes:
# This filter excludes any VM that matches the specified conditions.
# Therefore, define conditions using negative (not) matching so that only
# the desired VMs are included in the exported inventory.
#
# Example: Gather only VMs matching opsinfra*
#   - "config.name is not match('^opsinfra.*')"
#
# Example: Exclude VMs matching opscom*, opsctl*, or opsaz*
#   - "config.name is match('^ops(com|ctl|az).*')"

filter_expressions:
  # - "config.name is not match('^ops-(deployment|ansible).*')"
```

Ensure the filter expressions select only the VMs intended for migration.

## 3. Prepare Migration

Run the pre-migration process:

```bash
make pre_migrate
```

The pre-migration process performs the required preparation steps, including:

- Collecting the VMware VM inventory.
- Validating VM readiness for migration.
- Mapping VMware resources to the corresponding OpenStack resources.
- Generating the migration variable file required by os-migrate.

### Review Migration Readiness

Review the generated readiness results before starting the migration:

- `output/vm_data_readiness.json`: Lists the VMs that passed readiness validation and will be included in the migration.
- `output/vm_data_readiness_not_ready.json`: Lists the VMs that did not pass readiness validation.

Ensure that the expected VMs are listed in `output/vm_data_readiness.json`.

If a VM is listed in `output/vm_data_readiness_not_ready.json`, review and resolve the reported readiness issue before proceeding.

### Review Generated Migration Variables

The os-migrate migration variable files are generated based on the virt-v2v conversion policy assigned during readiness validation.

- With virt-v2v conversion (virt_v2v_enabled: true):

```bash
cat environments/$ENV/migration_vm_with_v2v.yml
```

- Without virt-v2v conversion (virt_v2v_enabled: false):

```bash
cat environments/$ENV/migration_vm_without_v2v.yml
```

Example:

```yaml
### Default Cinder Volume Type
cinder_volume_type: <cinder_volume_type>

### Default Security Group
security_groups: <security_group_id>

### Network Mapping from VMware to OpenStack
network_map:
  # "vmware_portgroup_id": "openstack_network_name,openstack_subnet_id"
  "<vmware_portgroup_id_01>": "<openstack_network_name_01>,<openstack_subnet_id_01>"

### Virt-v2v Configuration
skip_conversion: <not virt_v2v_enabled>

### VM Migration Readiness List
vms_list:
  - <vm_name>
```

Review `migration_vars.yml` and confirm that:

- The expected Cinder volume type is configured.
- The expected security group is configured.
- All required VMware port groups are mapped to the correct OpenStack networks and subnets.
- `skip_conversion` matches the intended conversion mode.
- `vms_list` contains only the VMs intended for migration.

## 4. Run Migration

After reviewing the readiness results and generated migration variables, start the migration:

### Migration

#### Migrate VMs with virt-v2v Conversion

```bash
make migrate_vm_with_v2v
```

#### Migrate VMs without virt-v2v Conversion

```bash
make migrate_vm_without_v2v
```

#### Migrate All VMs (Optional)

Executes both migration workflows sequentially:

- Migrate VMs with virt-v2v conversion.
- Migrate VMs without virt-v2v conversion.

```bash
make migrate_vm_all
```

### Cutover

By default, migration runs with `MIGRATION_CUTOVER=false`.

To perform the final migration cutover, set `MIGRATION_CUTOVER=true`.

#### With virt-v2v conversion

```bash
make migrate_vm_with_v2v MIGRATION_CUTOVER=true
```

#### Without virt-v2v conversion

```bash
make migrate_vm_without_v2v MIGRATION_CUTOVER=true
```

#### All VMs (Optional):

```bash
make migrate_vm_all MIGRATION_CUTOVER=true
```

### Migration Process

The migration process performs the following:

- Validates the required migration configuration files:
  - `./environments/$ENV/secrets.yml`: Contains the authentication parameters for VMware and OpenStack.
  - `./environments/$ENV/migration_settings.yml`: Contains the Red Hat os-migrate tool settings used during the migration.
  - `./environments/$ENV/migration_vm_with_v2v.yml` or `migration_vm_without_v2v.yml`: Contains the VM list, resource mappings, and virt-v2v conversion settings.
- Executes the VMware-to-OpenStack migration using Red Hat os-migrate.

Monitor the migration output for errors and verify that each selected VM completes the migration successfully.

## Troubleshooting

- [KB003 - Metadata Service Connection Failure During VM Migration.](../kb/kb003-metadata-service-unreachable.md)