# Ansible Execution Environment for OS Migrate

This folder builds the `vmware-migration-kit:latest` Ansible Execution
Environment image used by the migration playbooks. The image contains Ansible
Core, Ansible Runner, required collections, Python packages, system packages,
VMware and OpenStack CA certificates, and optional local patches for
`os_migrate.vmware_migration_kit`.

## Contents

| File or directory | Purpose |
| --- | --- |
| `execution-environment.yml` | Main `ansible-builder` definition. |
| `requirements.yml.template` | Source template for Ansible Galaxy collections and versions. |
| `requirements.txt` | Python packages installed with `pip`. |
| `bindep.txt` | System packages installed into the image. |
| `patches/` | Local patch scripts and file overlays copied into the build context. |
| `build_aee.sh` | Build wrapper used by `make build_aee`. |

`certs/` is created temporarily by `build_aee.sh` from `../certs/`.
`requirements.yml` is generated from `requirements.yml.template`. Both are
removed, along with `context/`, when the build script exits.

## Build the Image

Run the following commands from the `osmigrate` directory containing the
Makefile. Set `ENV` to the environment directory name:

```bash
export ENV="<TARGET_ENVIRONMENT>"
make build_aee
```

Set `OS_MIGRATE_VERSION` in `environments/${ENV}/.env` before building. It is
required to install the selected `os_migrate.vmware_migration_kit` collection
from Ansible Galaxy, including when `CUSTOM_PATCHES=none`. The current sample
uses `2.2.5`. Specify the version without a leading `v`.

To run the wrapper directly, supply the version explicitly. For example:

```bash
cd infra_os_migrate/aee
OS_MIGRATE_VERSION=2.2.5 CUSTOM_PATCHES=true ./build_aee.sh
```

The wrapper script:

1. Copies `infra_os_migrate/certs/` to `infra_os_migrate/aee/certs/`.
2. Generates `requirements.yml` from `requirements.yml.template` using the
   selected OS Migrate version.
3. Passes `OS_MIGRATE_VERSION` and `CUSTOM_PATCHES` as container build arguments.
   `CUSTOM_PATCHES` defaults to `true`.
4. Runs `ansible-builder build` with Docker, verbosity level 3, and plain
   progress output, tagging the image as `vmware-migration-kit:latest`.
5. Lists installed collections with `ansible-galaxy collection list` in the
   built image.
6. Removes the temporary `certs/` copy, `context/`, and generated
   `requirements.yml` on exit.

`docker-compose.yml` uses the same image name for the `ansible` service.

## Current Build Definition

`execution-environment.yml` currently uses:

```text
Base image: quay.io/centos/centos:stream9
Image tag:  vmware-migration-kit:latest
Python:     /usr/bin/python3.12
Ansible:    ansible-core~=2.21.0
Runner:     ansible-runner~=2.4.0
OS Migrate: OS_MIGRATE_VERSION from environments/${ENV}/.env
Patches:    CUSTOM_PATCHES=true by default
```

Ansible Builder installs:

- `ansible-core~=2.21.0` from `pip`.
- `ansible-runner~=2.4.0` from `pip`.
- system packages from `bindep.txt`.
- Python packages from `requirements.txt`.
- Ansible Galaxy collections from the generated `requirements.yml`.

The final image build also:

- Creates `/opt/os-migrate` and grants group-writable permissions for metadata
  export.
- Copies OpenStack and VMware `.crt` files into the system trust store.
- Runs `update-ca-trust extract`.
- Runs `patches/apply_patches.sh`.

## Update System Packages

Edit:

```text
infra_os_migrate/aee/bindep.txt
```

Current packages:

```text
openssh-clients
openssl
python3.12
jq
git
rsync
iputils
```

Add one package per line. Use package names available from the CentOS Stream 9
base image repositories.

When `CUSTOM_PATCHES=true`, `patches/apply_patches.sh` separately installs
`dnf-plugins-core`, enables CRB, and installs `golang`, `gcc`, and `libnbd-devel`
to build the patched Go binaries. These dependencies are no longer listed in
`bindep.txt`; the `none` patch mode skips this installation.

If changing the Python runtime package, update both places:

```yaml
dependencies:
  python_interpreter:
    package_system: "python3.12"
    python_path: "/usr/bin/python3.12"
```

Then rebuild:

```bash
make build_aee
```

## Update Python Packages

Edit:

```text
infra_os_migrate/aee/requirements.txt
```

Current packages:

```text
requests
pyVim
pyVmomi
PyYAML
openstacksdk
python-openstackclient
```

Add one package per line. Pin versions when the dependency is migration-critical
or when a newer release could change behavior.

Example:

```text
openstacksdk==4.4.0
python-openstackclient==7.4.0
```

Then rebuild and verify:

```bash
make build_aee
docker run --rm vmware-migration-kit:latest python3 -m pip list
```

## Update Ansible Collections

Edit:

```text
infra_os_migrate/aee/requirements.yml.template
```

Set the OS Migrate collection version in `environments/${ENV}/.env`:

```bash
OS_MIGRATE_VERSION="2.2.5"
```

This is the current sample value. `OS_MIGRATE_VERSION` selects the version of
`os_migrate.vmware_migration_kit` installed from Ansible Galaxy. The build
substitutes it into `requirements.yml.template` to generate `requirements.yml`.
This version is required for every build, regardless of `CUSTOM_PATCHES`.

Current collection template:

```yaml
collections:
  - name: os_migrate.vmware_migration_kit
    version: "OS_MIGRATE_VERSION"
  - name: vmware.vmware
    version: ">=2.8.0"
  - name: vmware.vmware_rest
    version: ">=4.10.0"
  - name: openstack.cloud
    version: ">=2.6.0"
  - name: community.general
  - name: community.vmware
  - name: ansible.posix
```

Use pinned versions for repeatable migration runs. Use version ranges only when
the workflow can safely accept newer compatible releases.

Edit `requirements.yml.template` to add or update other collections. The
generated `requirements.yml` is temporary and is removed on exit.

Then rebuild and verify:

```bash
make build_aee
docker run --rm vmware-migration-kit:latest ansible-galaxy collection list
```

## Update Ansible Core, Runner, Base Image

Edit `execution-environment.yml`.

To change the base image:

```yaml
images:
  base_image:
    name: quay.io/centos/centos:stream9
```

To specify Ansible Core or Runner versions, set package versions in the
`package_pip` values:

```yaml
dependencies:
  ansible_core:
    package_pip: "ansible-core~=2.21.0"
  ansible_runner:
    package_pip: "ansible-runner~=2.4.0"
```

Use `~=` for a compatible release range, or `==` when the image must use one
exact version.

After any change:

```bash
make build_aee
docker run --rm vmware-migration-kit:latest ansible --version
```

## Add or Rotate CA Certificates

The certificate source of truth is outside this folder:

```text
infra_os_migrate/certs/openstack/
infra_os_migrate/certs/vmware/
```

Use PEM encoded CA certificates with a `.crt` extension.

During `make build_aee`, `build_aee.sh` copies `../certs/` into the local build
context as `aee/certs/`. The `execution-environment.yml` then copies all
matching certificates into:

```text
/etc/pki/ca-trust/source/anchors/
```

and runs:

```bash
update-ca-trust extract
```

No `execution-environment.yml` change is required when adding or replacing a
`.crt` file in the existing `openstack` or `vmware` certificate directories.

After certificate changes:

```bash
make build_aee
make setup_conversion
```

Use `make setup_conversion` when the conversion host also needs the updated CA
trust. For a targeted conversion-host certificate update:

```bash
docker compose run --rm --user 0:0 ansible "ansible-playbook ansible/playbooks/setup_conversion.yml -i environments/${ENV}/inventory -e @environments/${ENV}/migration_settings.yml -t certs -v"
```

## Custom Patches on Demand

The patch entry point is:

```text
infra_os_migrate/aee/patches/apply_patches.sh
```

The current patches are:

```text
infra_os_migrate/aee/patches/migration_enhancements/
infra_os_migrate/aee/patches/workload_converted/patch.py
```

`apply_patches.sh` supports these values:

- `CUSTOM_PATCHES=true`: apply the `migration_enhancements` file overlay,
  run the `workload_converted` code patch, and rebuild the Go binaries.
- `CUSTOM_PATCHES=none`: skip custom patches.

Only `true` and `none` are accepted by the script's case branches.

The default patch mode is `true`. `build_aee.sh` passes both values to the
container build:

```bash
--build-arg CUSTOM_PATCHES=${CUSTOM_PATCHES}
--build-arg OS_MIGRATE_VERSION=${OS_MIGRATE_VERSION}
```

When `CUSTOM_PATCHES=true`, `OS_MIGRATE_VERSION` is also used to fetch the
upstream Go source from tag `v${OS_MIGRATE_VERSION}`. Using the same version
for the Galaxy collection and the upstream tag keeps the restored Go source
on the same release as the installed collection before custom patches are
applied and the binaries are rebuilt. Review patch compatibility when changing
versions.

With `CUSTOM_PATCHES=none`, the build installs the selected Galaxy collection
without fetching or restoring upstream Go source.

The custom patch workflow is:

1. Clones `os-migrate/vmware-migration-kit` tag `v${OS_MIGRATE_VERSION}`.
2. Copies the upstream `plugins/modules/src` Go source back into the installed
   collection because the published collection excludes that source directory.
3. Overlays files from `patches/migration_enhancements/` onto the installed
   collection.
4. Runs `workload_converted/patch.py` against the overlaid `nbdkit.yml` to
   update `import_workloads_converted` for skipped conversion, CBT sync, and
   cutover workflows.
5. Installs the Go build dependencies and enables CRB.
6. Builds each Go `main` package under `plugins/modules/src/` into
   `plugins/modules/<module_name>`, replacing the installed module binaries.
   For other packages, it creates symlinks to `module_dispatcher`.

The patch overlay currently updates:

- `roles/import_workloads/tasks/nbdkit.yml`
- `roles/export_metadata/tasks/network.yml`
- `plugins/modules/migrate.py`
- `plugins/modules/src/migrate/migrate.go`
- `plugins/module_utils/nbdkit/nbdkit.go`
- `plugins/module_utils/openstack/openstack.go`

The current `execution-environment.yml` runs the patch entry point with:

```yaml
- ARG OS_MIGRATE_VERSION
- ARG CUSTOM_PATCHES=true
- COPY _build/patches/ /tmp/patches/
- RUN bash /tmp/patches/apply_patches.sh
- RUN rm -rf /tmp/patches/
```

Build with patches:

```bash
make build_aee
```

or explicitly:

```bash
make build_aee ENV="$ENV" CUSTOM_PATCHES=true
```

Build without custom patches:

```bash
make build_aee ENV="$ENV" CUSTOM_PATCHES=none
```

Passing `CUSTOM_PATCHES` as a Make command-line variable overrides its value
in the environment file.

To verify the patch mode used by the build, review the plain build output for
these messages for a patched build:

```text
File patch applied: migration_enhancements
Applying code patch: workload_converted
Go binaries built successfully.
```

An unpatched build reports:

```text
Using original collection.
```

## Maintenance Checklist

Before committing AEE changes:

1. Update the relevant file: `bindep.txt`, `requirements.txt`,
   `requirements.yml.template`, `execution-environment.yml`, certificates,
   patch files under `patches/`, or `OS_MIGRATE_VERSION` in the environment file.
2. Rebuild with `make build_aee`.
3. Verify installed package or collection versions as needed.
4. Run `make validate_connectivity` or the relevant migration playbook check.
5. Document why any local patch is still required.
