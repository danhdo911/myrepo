# Migration Infrastructure

This directory contains the scripts and assets used to prepare the migration
runtime: the migrator host, Ansible Execution Environment, conversion host,
certificates, and generated Ansible inventory.

For the end-to-end preparation procedure, see
[`docs/runbooks/guide/os_migrate_infrastructure_preparation.md`](../docs/runbooks/guide/os_migrate_infrastructure_preparation.md).
For AEE package, dependency, collection, certificate, and patch maintenance, see
[`aee/README.md`](./aee/README.md).

## Directory Layout

```text
infra_os_migrate/
|-- aee/
|   |-- bindep.txt
|   |-- build_aee.sh
|   |-- execution-environment.yml
|   |-- patches/
|   |-- requirements.txt
|   `-- requirements.yml.template
|-- ansible_inventory/
|   `-- generate_inventory.sh
|-- certs/
|   |-- openstack/
|   `-- vmware/
|-- conversion/
|   `-- deploy_conversion.sh
|-- migrator/
|   `-- setup_migrator.sh
`-- scripts/
    `-- configure_docker_proxy.sh
```

## Components

| Path | Purpose | Main entry point |
| --- | --- | --- |
| `migrator/` | Automatically configures the Docker proxy when defined, then prepares the local migrator host with required OS packages, Python tooling, `ansible-builder`, Docker, and sample environment files. | `make build_migrator` |
| `scripts/` | Contains the Docker daemon and client proxy helper, which skips proxy configuration when `PROXY_URL` is undefined or empty. | Invoked automatically by `make build_migrator` |
| `aee/` | Builds the `vmware-migration-kit:latest` Ansible Execution Environment image used by Docker Compose. The image uses CentOS Stream 9, Python 3.12, specified Ansible Core and Runner versions, certificates, and optional custom patches. | `make build_aee` |
| `certs/` | Stores OpenStack and VMware CA certificates shared by the AEE image and conversion host setup. | Update `certs/openstack/*.crt` or `certs/vmware/*.crt` |
| `conversion/` | Deploys or reuses the OpenStack conversion host and prepares the CentOS Stream 10 image, flavor, keypair, security group, network, boot volume, and optional floating IP resources. | `make deploy_conversion` |
| `ansible_inventory/` | Generates `environments/${ENV}/inventory` for the migrator and conversion host. | `make generate_inventory` |

## Main Workflow

Run from the `osmigrate` directory. Set `ENV` to the environment directory name
under `environments/`. Before starting, create the selected environment from
`samples/sample_environment/`, copy its `.env.sample` to `.env`, and configure
the values for that environment.

```bash
export ENV="<TARGET_ENVIRONMENT>"

make build_migrator ENV=$ENV
make build_aee ENV=$ENV
make build_conversion ENV=$ENV
```

`make build_migrator` automatically runs the Docker proxy helper before host
setup. The helper loads `environments/${ENV}/.env` and skips proxy configuration
when `PROXY_URL` is undefined or empty. When a proxy is configured, it applies
`PROXY_URL` and `NO_PROXY` to the Docker daemon and client. No separate proxy
command is needed.

Set `OS_MIGRATE_VERSION` in the environment file to select the collection
version installed from Ansible Galaxy. When custom patches are enabled, the
same version also selects matching upstream Go source.

`make build_aee` applies custom AEE patches by default. To build the original
`os_migrate.vmware_migration_kit` collection without local patch overlays:

```bash
make build_aee ENV="$ENV" CUSTOM_PATCHES=none
```

`make build_conversion` chains the conversion workflow:

```text
deploy_conversion -> generate_inventory -> validate_aee_to_conv -> setup_conversion
```

`setup_conversion` applies the conversion-host Ansible configuration, including
DNS records, CA certificates, and VMware VDDK installation.

`deploy_conversion` requires OpenStack authentication from the environment file
and a `CONVERSION_NETWORK`. It can use `CONVERSION_STATIC_IP` and
`CONVERSION_FLOATING_IP`, or allocate a floating IP from
`CONVERSION_FLOATING_NETWORK` when configured.

## Notes

- The environment file `environments/<TARGET_ENVIRONMENT>/.env` must exist before running `make build_migrator`, including when no proxy is required.
- Keep `ENV` aligned with the environment directory name when running `make` targets.
- Configure DNS records for VMware and OpenStack endpoints in `/etc/hosts` and `environments/<TARGET_ENVIRONMENT>/group_vars/dns.yml`.
- Place the VMware VDDK package under `/tmp/` on the migrator host, then update `vddk_archive` in `environments/<TARGET_ENVIRONMENT>/group_vars/conversion_host.yml`.
- Update VMware and OpenStack CA certificates in `certs/vmware/` and `certs/openstack/`, then rebuild the AEE image and rerun `make setup_conversion ENV=$ENV` when the conversion host also needs the updated trust store.
- When a proxy is required, set `PROXY_URL` and `NO_PROXY` in `environments/<TARGET_ENVIRONMENT>/.env` before running `make build_migrator ENV=$ENV`. Otherwise, leave `PROXY_URL` undefined or empty to skip proxy configuration automatically.
