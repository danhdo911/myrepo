#

## Ansible Galaxy Collection Download Issue

### Issue

During the Ansible Execution Environment (AEE) build, the ansible-galaxy collection install step may fail while downloading the os_migrate.
vmware_migration_kit collection.

```bash
Building Ansible Execution Environment (AEE) image...
Running command:
  docker build -f context/Dockerfile -t vmware-migration-kit --progress=plain context
...showing last 20 lines of output...
#16 183.0 Starting collection install process
#16 183.0 Downloading https://galaxy.ansible.com/api/v3/plugin/ansible/content/published/collections/artifacts/os_migrate-vmware_migration_kit-2.2.7.tar.gz to /root/.ansible/tmp/ansible-local-1zzdn2wn8/tmp2pidvwt4/os_migrate-vmware_migration_kit-2.2.7-r4d066j8
#16 ERROR: process "/bin/sh -c ANSIBLE_GALAXY_DISABLE_GPG_VERIFY=1 ansible-galaxy collection install $ANSIBLE_GALAXY_CLI_COLLECTION_OPTS -r requirements.yml --collections-path \"/usr/share/ansible/collections\"" did not complete successfully: exit code: 1
------
 > [galaxy 6/6] RUN ANSIBLE_GALAXY_DISABLE_GPG_VERIFY=1 ansible-galaxy collection install  -r requirements.yml --collections-path "/usr/share/ansible/collections":
183.0 [ERROR]: Failed to download collection tar from 'default' due to the following unforeseen error: The read operation timed out
183.0 Starting galaxy collection install process
183.0 Process install dependency map
183.0 Starting collection install process
183.0 Downloading https://galaxy.ansible.com/api/v3/plugin/ansible/content/published/collections/artifacts/os_migrate-vmware_migration_kit-2.2.7.tar.gz to /root/.ansible/tmp/ansible-local-1zzdn2wn8/tmp2pidvwt4/os_migrate-vmware_migration_kit-2.2.7-r4d066j8
------
Dockerfile:46
--------------------
  44 |     RUN mkdir -p /usr/share/ansible
  45 |     RUN ansible-galaxy role install $ANSIBLE_GALAXY_CLI_ROLE_OPTS -r requirements.yml --roles-path "/usr/share/ansible/roles"
  46 | >>> RUN ANSIBLE_GALAXY_DISABLE_GPG_VERIFY=1 ansible-galaxy collection install $ANSIBLE_GALAXY_CLI_COLLECTION_OPTS -r requirements.yml --collections-path "/usr/share/ansible/collections"
  47 |
  48 |     # Builder build stage
--------------------
ERROR: failed to solve: process "/bin/sh -c ANSIBLE_GALAXY_DISABLE_GPG_VERIFY=1 ansible-galaxy collection install $ANSIBLE_GALAXY_CLI_COLLECTION_OPTS -r requirements.yml --collections-path \"/usr/share/ansible/collections\"" did not complete successfully: exitcode: 1

An error occurred (rc=1), see output line(s) above for details.
make: *** [Makefile:51: build_aee] Error 1
```

### Cause

The Ansible Galaxy endpoint is reachable, but the network throughput to the collection artifact is very low.

A direct download test may return HTTP 200 OK, but the transfer speed can be too slow for ansible-galaxy to complete before the read timeout occurs.

This causes the AEE build to fail during the Galaxy collection installation stage.

### Verification

Test the collection download directly from the migrator host:

```bash
curl -v \
  --connect-timeout 30 \
  --max-time 7200 \
  -o /tmp/os_migrate-vmware_migration_kit-2.2.7.tar.gz \
  "https://galaxy.ansible.com/api/v3/plugin/ansible/content/published/collections/artifacts/"
```

### Workaround

Pre-download the required collection locally and use the local archive during the AEE build.

#### Download the collection:

Change to the AEE setup directory:

```bash
cd ./infra_os_migrate/aee
```

Create the collection directory:

```bash
mkdir -p collections
```

Download the collection:

```bash
curl -fL \
  --retry 5 \
  --retry-delay 10 \
  --continue-at - \
  --connect-timeout 30 \
  --max-time 7200 \
  -o collections/os_migrate-vmware_migration_kit-2.2.7.tar.gz \
  "https://galaxy.ansible.com/api/v3/plugin/ansible/content/published/collections/artifacts/os_migrate-vmware_migration_kit-2.2.7.tar.gz"
```

Validate the downloaded archive:

```bash
tar -tzf collections/os_migrate-vmware_migration_kit-2.2.7.tar.gz >/dev/null
```

#### Build AEE with the local collection archive

Edit the AEE definition:

```bash
nano execution-environment.yml
```

Add the collection archive to the AEE build context:

```bash
additional_build_files:
  - src: collections/os_migrate-vmware_migration_kit-2.2.7.tar.gz
    dest: collections
```

Install the collection from the local archive during the AEE build:

```bash
additional_build_steps:
  prepend_galaxy:
    - COPY _build/collections/os_migrate-vmware_migration_kit-2.2.7.tar.gz /tmp/

  append_galaxy:
    - >-
      RUN ansible-galaxy collection install
      /tmp/os_migrate-vmware_migration_kit-2.2.7.tar.gz
      --collections-path /usr/share/ansible/collections
```

Remove `os_migrate.vmware_migration_kit` from the online Galaxy dependencies in `requirements.yml` to prevent the build from downloading it again.

```bash
collections:
#  - name: os_migrate.vmware_migration_kit
#    version: "2.2.7"
...
```

The AEE build will now install os_migrate.vmware_migration_kit from the local archive instead of downloading it from Ansible Galaxy.
