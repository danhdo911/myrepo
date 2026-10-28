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

```bash
./bootstrap.sh
```

### Validation OpenStack Network
#### On controller
./validation.sh ens33 \
172.16.85.11 \
172.16.85.12 \
172.16.85.13 \
172.16.85.14 \
172.16.85.15

./validation.sh ens34 \
172.16.85.11 \
172.16.88.12 \
172.16.88.13

./validation.sh ens36 \
172.16.85.11 \
172.16.87.12 \
172.16.87.13 \
172.16.87.14 \
172.16.87.15 

#### On compute
./validation.sh ens33 \
172.16.85.11 \
172.16.85.12 \
172.16.85.13 \
172.16.85.14 \
172.16.85.15

./validation.sh ens35 \
172.16.85.14 \
172.16.86.15

./validation.sh ens36 \
172.16.87.11 \
172.16.87.12 \
172.16.87.13 \
172.16.85.14 \
172.16.87.15 

### CEPH Installation

```bash
./install_ceph.sh
```

Run if Public and Cluster network seprated.

```bash
cephadm --image quay.io/ceph/ceph:v20.2.4 bootstrap \
    --mon-ip=172.16.87.11 \
    --cluster-network 172.16.88.0/24 \
    --initial-dashboard-user admin \
    --initial-dashboard-password='P@ssw0rd' \
    --dashboard-password-noupdate \
    --allow-fqdn-hostname | tee cephadm-bootstrap.log
```

Run if Public and Cluster network are the same newtork.

```bash
cephadm --image quay.io/ceph/ceph:v20.2.4 bootstrap \
    --mon-ip=172.16.87.11 \
    --initial-dashboard-user admin \
    --initial-dashboard-password='P@ssw0rd' \
    --dashboard-password-noupdate \
    --allow-fqdn-hostname | tee cephadm-bootstrap.log
```