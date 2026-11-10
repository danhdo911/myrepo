#

## Workflow

```text
+-- System initialization
|     +-- Hostname / FQDN
|     +-- Timezone / NTP
|     +-- Cloud-init / Firewall
|     +-- Connectivity validation
|
+-- Install OS packages
|     +-- Common
|     +-- OpenStack prerequisites
|     +-- Ceph prerequisites
|     +-- Python
|
+-- Install Docker Engine
|
+-- Install Podman Engine
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

## OS Baseline

Perform the following tasks on all nodes:

- [ ] Run the OS bootstrap script.
- [ ] Configure hostname resolution in `/etc/hosts`.
- [ ] Validate network connectivity between all nodes.

### Bootstrap

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

### Network Connectivity Validation

#### On controller

```bash
./network_validation ens33 \
172.16.85.11 \
172.16.85.12 \
172.16.85.13 \
172.16.85.14 \
172.16.85.15 \
172.16.85.16

./network_validation ens34 \
172.16.85.11 \
172.16.88.12 \
172.16.88.13

./network_validation ens36 \
172.16.85.11 \
172.16.87.12 \
172.16.87.13 \
172.16.87.14 \
172.16.85.15 \
172.16.85.16
```

#### On compute

```bash
./network_validation ens33 \
172.16.85.11 \
172.16.85.12 \
172.16.85.13 \
172.16.85.14 \
172.16.85.15 \
172.16.85.16

./network_validation ens35 \
172.16.85.14 \
172.16.85.15 \
172.16.85.16

./network_validation ens36 \
172.16.87.11 \
172.16.87.12 \
172.16.87.13 \
172.16.85.14 \
172.16.85.15 \
172.16.85.16
```

## CEPH Installation

[CEPH Installation](./ceph_installation.md).

- [ ] Bootstrap Ceph on Controller 01
- [ ] Register all Ceph hosts
- [ ] Deploy 5 MONs
- [ ] Deploy 2 MGRs
- [ ] Add lables: admin, mon, mgr, osd, etc.
- [ ] Validate dedicated OSD disks
- [ ] Deploy OSDs
- [ ] Verify cluster health
- [ ] Create RBD pools
- [ ] Configure CephX users

## OpenStack Deployment (On Infrastructure node)

### Pre-deployment: Kolla Preparation

Install kolla-ansible packages and prepare python environment.

```bash
chmod +x kolla_preparation.sh
./kolla_preparation.sh
```

Configure Ceph's keyrings for OpenStack services.

```bash
chmod +x kolla_ceph_configure.sh
./kolla_ceph_configure.sh
```

Configure for Nova service.

```bash
cp kolla_ansible/config/nova/nova.conf /etc/kolla/config/nova/nova.conf
```

Configure for Neutron service.

```bash
cp kolla_ansible/config/neutron/ml2_conf.ini /etc/kolla/config/neutron/ml2_conf.ini
```

Create folders for HA service.

```bash
mkdir -p /etc/kolla/config/hacluster-corosync
mkdir -p /etc/kolla/config/hacluster-pacemaker
```

Test connection using ansible and ping module.

```bash
source workdir/openstack/os-venv/bin/activate
```

```bash
ansible -i workdir/openstack/multinode all -m ping
```

Generate Password for every OpenStack services.

```bash
kolla-genpwd
```

Pull images for OpenStack services.

```bash
kolla-ansible pull -i workdir/openstack/multinode
```

Generate TLS Certificates for OpenStack services.

```bash
kolla-ansible certificates -i workdir/openstack/multinode
```

### Bug fix: Custom OpenStack services image (Cinder, Glance, Nova)

[Build custom image with Ceph 2.20.4 version](./kolla_custom_image.md)

### Deployment OpenStack with Kolla-Ansible

```bash
kolla-ansible bootstrap-servers -i workdir/openstack/multinode
```

```bash
kolla-ansible prechecks -i workdir/openstack/multinode
```

```bash
kolla-ansible deploy -i workdir/openstack/multinode
```

```bash
kolla-ansible post-deploy -i workdir/openstack/multinode
```

### Post-deployment: Verify OpenStack services

```bash
cat /etc/kolla/certificates/ca/root.crt | sudo tee -a /etc/ssl/certs/ca-certificates.crt
```

```bash
echo "export OS_CACERT=/etc/ssl/certs/ca-certificates.crt" >> /etc/kolla/admin-openrc.sh
```

```bash
pip3 install python-openstackclient
```

```bash
source /etc/kolla/admin-openrc.sh

openstack endpoint list
openstack service list
openstack compute service list
openstack network agent list
openstack volume service list
```

## Validation OpenStack services

Create external network (notes: set gateway for external vlan, no need create static route on OVN Router)
Create private network for tenant
Create OVN router
Upload image
Create instance
Check network connectivity

### Configure Masakari for HA

```bash
source /etc/kolla/admin-openrc.sh
```

```bash
pip3 install python-masakariclient
```

```bash
openstack segment create \
  --service-type COMPUTE \
  --recovery-method auto \
  compute-ha
```

```bash
openstack segment host create <fqdn_compute_nodes> COMPUTE SSH compute-ha
```
