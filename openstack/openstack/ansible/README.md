# Ansible Automation

This directory contains the Ansible automation used around the OpenStack deployment lifecycle: host baseline provisioning, Kolla-Ansible configuration generation, deployment handoff, post-deployment OpenStack configuration, and operational health checks.

## Directory Structure

```text
ansible/
|-- ansible.cfg                     # Local Ansible defaults
|-- ansible.dockerfile              # Container image definition for Ansible runtime
|-- docker-compose.yml              # Containerized Ansible runner
|-- requirements/                   # Runtime dependencies
|   |-- collections.yml             # Ansible Galaxy collections
|   |-- requirements.apt            # OS packages
|   `-- requirements.txt            # Python packages
|-- playbooks/
|   |-- os_baseline_setup.yml       # Infrastructure provisioning / OS baseline
|   |-- kolla_config.yml            # Kolla pre-deployment configuration generation
|   |-- ops_auth_fetch.yml          # Fetch OpenStack auth files and CA artifacts
|   |-- ops_postdeploy.yml          # Post-deployment OpenStack configuration
|   |-- ops_healthcheck.yml         # OpenStack service health checks
|   |-- templates/
|   |   `-- globals_config/         # globals.yml templates for Kolla-Ansible
|   `-- roles/
|       |-- os_baseline_setup/      # OS baseline setup tasks
|       |-- kolla_init/             # Kolla-Ansible environment bootstrap
|       |-- kolla_core_services/    # Core OpenStack service configuration
|       |-- kolla_skyline_rbac/     # Skyline/OpenStack policy integration
|       |-- kolla_higio_portal/     # HIGIO Portal integration
|       |-- kolla_ldap_horizon/     # LDAP Horizon integration
|       |-- kolla_monitoring/       # Monitoring integration
|       |-- ops_flavors/            # OpenStack flavor definitions
|       |-- ops_qos/                # Cinder QoS volume definitions
|       `-- ops_healthcheck/        # Health check tasks and scripts
`-- scripts/
    |-- kolla_test/                 # Kolla test helper scripts
    |-- mariadb/                    # MariaDB backup, custom config, and alert scripts
    `-- render_inventory/           # Inventory rendering helper
```

Legacy or experimental directories may also exist under `playbooks/` and `playbooks/roles/`. The main workflow below focuses on the active OpenStack deployment path.

## Main Workflow

### 1. OS Baseline

Playbook: `playbooks/os_baseline_setup.yml`

Role: `playbooks/roles/os_baseline_setup`

This stage prepares the operating system before OpenStack deployment. It configures the host baseline for OpenStack nodes, including network setup, cloud-init, hostname, proxy, DNS, essential packages, NTP, Docker, NFS mounts, Kolla SSH access, OS hardening, and administration SSH configuration.

```bash
ansible-playbook -i <inventory> playbooks/os_baseline_setup.yml
```

The playbook can be executed by phase using the following main tags:

- `pre_setup` – Initial host preparation. Additional tags: `netplan`.
- `setup` – Core operating system configuration. Additional tags: `cloud_init`, `hostname`, `proxy`, `dns`, `packages`, `ntp`, `docker`, `nfs`, `ssh_kolla`.
- `post_setup` – System hardening and administration configuration. Additional tags: `hardening_os`, `ssh`.

### 2. Pre-deployment: Kolla Configuration

Playbook: `playbooks/kolla_config.yml`

This stage prepares Kolla-Ansible and generates configuration files for OpenStack. It does not deploy OpenStack services. Deployment is handled later by running `kolla-ansible` commands.

```bash
ansible-playbook -i <inventory> playbooks/kolla_config.yml
```

Pre-deployment is split into Kolla initialization and Kolla configuration workflows.

Kolla initialization:

- Role: `playbooks/roles/kolla_init`
- Prepares packages, Python virtual environment, Kolla-Ansible installation, passwords, inventory, and private registry configuration.
- Main tag: `kolla_init`
- Additional tags: `packages`, `kolla_venv`, `passwords_config`, `inventory`, `registry_config`

Kolla configuration workflows:

1. Core services configuration
   - Role: `playbooks/roles/kolla_core_services`
   - Default OpenStack service configuration stage.
   - Includes Nova, Neutron, Cinder, Glance, Skyline, Cinder NFS backend, and Neutron Provider VLAN networking.
   - Controlled by `core_services_enabled`, `skyline_enabled`, and `cinder_san_storage_enabled` (default).
   - Optional: `cinder_nfs_storage_enabled`, `neutron_provider_vlan_enabled`.
   - Only one Cinder backend can be enabled at a time: SAN (`cinder_san_storage_enabled`) or NFS (`cinder_nfs_storage_enabled`).
   - Main tag: `kolla_core_services`
   - Additional tags: `nova`, `neutron`, `cinder`, `nfs_glance`, `skyline`, `cinder_nfs_storage`

2. Skyline policy integration
   - Role: `playbooks/roles/kolla_skyline_rbac`
   - Integrates Skyline and OpenStack RBAC policy configuration.
   - Controlled by `skyline_policy_enabled`.
   - Main tag: `kolla_skyline_rbac`
   - Additional tags: `custom_roles`, `horizon_policy`, `skyline_policy`

3. HIGIO Portal integration
   - Role: `playbooks/roles/kolla_higio_portal`
   - Integrates for Keystone and Skyline SSO.
   - Controlled by `higio_portal_enabled`.
   - Main tag: `kolla_higio_portal`
   - Additional tags: `nfs_metadata`

4. LDAP Horizon integration
   - Role: `playbooks/roles/kolla_ldap_horizon`
   - Integrates for Horizon LDAP.
   - Controlled by `ldap_horizon_enabled`.
   - Main tag: `kolla_ldap_horizon`
   - Additional tags: `ldap_domain`, `ldap_config`, `ldap_horizon_custom`

5. Monitoring system integration
   - Role: `playbooks/roles/kolla_monitoring`
   - Integrates for monitoring system.
   - Controlled by `monitoring_enabled`.
   - Main tag: `kolla_monitoring`
   - Additional tags: `dns_monitor`, `prometheus_config`

The same playbook also generates Kolla `globals.yml` from `playbooks/templates/globals_config/globals.yml.j2` into `{{ kolla_dir }}/globals.yml`.

Run only selected stages with tags:

```bash
ansible-playbook -i <inventory> playbooks/kolla_config.yml --tags kolla_init
ansible-playbook -i <inventory> playbooks/kolla_config.yml --tags kolla_core_services
ansible-playbook -i <inventory> playbooks/kolla_config.yml --tags kolla_skyline_rbac
ansible-playbook -i <inventory> playbooks/kolla_config.yml --tags globals_config
```

### 3. Deployment: Kolla-Ansible

After the pre-deployment configuration is generated, deploy OpenStack services from the Kolla-Ansible environment prepared on the infra node.

Default paths from `kolla_init`:

- Kolla config directory: `/etc/kolla`
- Kolla virtual environment: `~/workdir/openstack/os-venv`
- Kolla inventory: `~/workdir/openstack/multinode`

Typical deployment flow:

```bash
source ~/workdir/openstack/os-venv/bin/activate
kolla-ansible -i ~/workdir/openstack/multinode pull
kolla-ansible -i ~/workdir/openstack/multinode certificates
kolla-ansible -i ~/workdir/openstack/multinode bootstrap-servers
kolla-ansible -i ~/workdir/openstack/multinode prechecks
kolla-ansible -i ~/workdir/openstack/multinode deploy
kolla-ansible -i ~/workdir/openstack/multinode post-deploy
```

### 4. Post-deployment: OpenStack Configuration

Playbook: `playbooks/ops_postdeploy.yml`

This stage applies additional OpenStack configuration after services are deployed. The playbook imports `playbooks/ops_auth_fetch.yml` first to fetch `clouds.yaml` and the OpenStack CA certificate into the local artifacts path.

```bash
ansible-playbook -i <inventory> playbooks/ops_postdeploy.yml
```

Post-deployment components:

1. Authentication artifact fetch
   - Playbook: `playbooks/ops_auth_fetch.yml`
   - Fetches `clouds.yaml` and the OpenStack CA certificate.
   - Tag: `ops_auth_fetch`

2. CA export
   - Adds the OpenStack CA certificate path to `admin-openrc.sh`.
   - Tag: `addcerts`

3. Flavors
   - Role: `playbooks/roles/ops_flavors`
   - Creates OpenStack flavors template.
   - Tag: `flavors`

4. QoS volume
   - Role: `playbooks/roles/ops_qos`
   - Creates Cinder QoS specs and associates them with volume types.
   - Tag: `qos_volume`

Run selected post-deployment tasks:

```bash
ansible-playbook -i <inventory> playbooks/ops_postdeploy.yml --tags flavors
ansible-playbook -i <inventory> playbooks/ops_postdeploy.yml --tags qos_volume
```

### 5. Post-deployment: OpenStack Health Check

Playbook: `playbooks/ops_healthcheck.yml`

Role: `playbooks/roles/ops_healthcheck`

This stage runs operational health checks for OpenStack services. The current playbook runs service and container health checks through the `ops_healthcheck` role.

```bash
ansible-playbook -i <inventory> playbooks/ops_healthcheck.yml
```

Run selected health checks:

```bash
ansible-playbook -i <inventory> playbooks/ops_healthcheck.yml --tags healthcheck_services
ansible-playbook -i <inventory> playbooks/ops_healthcheck.yml --tags healthcheck_containers
```

## Lifecycle Summary

```text
1. OS baseline
   playbooks/os_baseline_setup.yml
      roles/os_baseline_setup

2. Kolla pre-deployment configuration
   playbooks/kolla_config.yml
      roles/kolla_init
      roles/kolla_core_services
      roles/kolla_skyline_rbac
      roles/kolla_higio_portal
      roles/kolla_ldap_horizon
      roles/kolla_monitoring  

3. OpenStack deployment
   kolla-ansible pull
   kolla-ansible certificates
   kolla-ansible bootstrap-servers
   kolla-ansible prechecks
   kolla-ansible deploy
   kolla-ansible post-deploy

4. OpenStack post-deployment configuration
   playbooks/ops_postdeploy.yml
      roles/ops_flavors
      roles/ops_qos

5. OpenStack health check
   playbooks/ops_healthcheck.yml
      roles/ops_healthcheck
```

---
This document was generated with AI assistance through vibe coding and validated by [IIJ-DanhDo](https://github.com/IIJ-DanhDo).
