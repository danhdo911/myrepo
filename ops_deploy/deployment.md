#

## Workflow

```text
bootstrap.sh
    |
    +-- System initialization
    |     +-- Hostname / FQDN
    |     +-- Timezone / NTP
    |     +-- Cloud-init / Firewall
    |
    +-- Install OS packages
    |     +-- Common
    |     +-- OpenStack prerequisites
    |     +-- Ceph prerequisites
    |     +-- Python
    |
    +-- Install Docker Engine 28.5.1
    |
    +-- Setup Ceph
    |     +-- Configure Ceph repository
    |     +-- Install Cephadm
    |     +-- Deploy Ceph cluster
    |
    +-- Deploy OpenStack 2026.1
          +-- Kolla-Ansible bootstrap
          +-- Prechecks
          +-- Deploy
```

## Deployment

### OS Baseline

Run bootstrap to setup os baseline: configuring hostname, ntp, timezone, firewall
and required Ceph, Python, Openstack packages.

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

Configure DNS in `etc/hosts`:

```bash
cat dns_hosts.conf | sudo tee -a /etc/hosts > /etc/null
```

### Validation OpenStack Network

#### On controller

./bootstrap_validation.sh ens33 \
172.16.85.11 \
172.16.85.12 \
172.16.85.13 \
172.16.85.14 \
172.16.85.15 \
172.16.85.16

./bootstrap_validation.sh ens34 \
172.16.85.11 \
172.16.88.12 \
172.16.88.13

./bootstrap_validation.sh ens36 \
172.16.85.11 \
172.16.87.12 \
172.16.87.13 \
172.16.87.14 \
172.16.85.15 \
172.16.85.16

#### On compute

./bootstrap_validation.sh ens33 \
172.16.85.11 \
172.16.85.12 \
172.16.85.13 \
172.16.85.14 \
172.16.85.15 \
172.16.85.16

./bootstrap_validation.sh ens35 \
172.16.85.14 \
172.16.85.15 \
172.16.85.16

./bootstrap_validation.sh ens36 \
172.16.87.11 \
172.16.87.12 \
172.16.87.13 \
172.16.85.14 \
172.16.85.15 \
172.16.85.16

## CEPH Installation

[CEPH Installation](./ceph_installation.md).

[x] Bootstrap Ceph on Controller 01
[ ] Register all Ceph hosts
[ ] Deploy 5 MONs
[ ] Deploy 2 MGRs
[ ] Validate dedicated OSD disks
[ ] Deploy OSDs
[ ] Verify cluster health
[ ] Create RBD pools
[ ] Configure CephX users
[ ] Integrate Ceph with Kolla-Ansible
[ ] Validate Glance, Cinder and Nova storage