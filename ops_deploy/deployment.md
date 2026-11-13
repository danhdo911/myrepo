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

## Physical Setup

### Server

- [ ] Configure server management: hostname, management IP, and console access.
- [ ] Verify hardware specifications: CPU, memory, NICs, and disk capacity.
- [ ] Verify BIOS/UEFI settings: UEFI boot mode, and boot order.
- [ ] Configure OS disks: RAID 1.
- [ ] Configure Ceph OSD disks: JBOD/HBA passthrough (recommended) or single-disk RAID 0.
- [ ] Verify hardware health: disks, memory, power supplies, and network interfaces.
- [ ] Install Ubuntu Server 24.04.5 LTS on all nodes.
- [ ] Enable CPU virtualization (Intel VT-x/AMD-V) for KVM on OpenStack Compute nodes.
- [ ] Configure physical network connectivity: switch ports, VLANs, bonding, and MTU.

### Network

- [ ] Configure switch management: hostname, management IP, gateway, and administrative access.
- [ ] Configure switch stacking or MLAG/vPC for high availability, as supported.
- [ ] Configure port groups and link aggregation (LACP/Port-Channel).
- [ ] Configure required VLANs for management, OpenStack API, tenant, provider, and Ceph networks.
- [ ] Configure access and trunk ports with the appropriate allowed VLANs.
- [ ] Configure MTU and jumbo frames where required.
- [ ] Configure inter-switch links and network redundancy.
- [ ] Configure routing and gateway connectivity where required.
- [ ] Validate switch connectivity, LACP status, VLANs, and network redundancy.

## OS Baseline

Perform the following tasks on all nodes:

- [ ] Run the OS bootstrap script.
- [ ] Configure hostname resolution in /etc/hosts or DNS.
- [ ] Configure network interfaces, bonding, VLANs, and routing.
- [ ] Configure NTP/Chrony for time synchronization.
- [ ] Configure SSH access and administrative users.
- [ ] Configure package repositories and proxy settings (if required).
- [ ] Install required OS packages and dependencies.
- [ ] Disable Firewall service.
- [ ] Disable Cloud-init service.
- [ ] Validate network connectivity between all nodes.
- [ ] Validate DNS resolution and time synchronization.
- [ ] Validate dedicated Ceph OSD disks.

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
./network_validation.sh ens33 \
172.16.85.11 \
172.16.85.12 \
172.16.85.13 \
172.16.85.14 \
172.16.85.15 \
172.16.85.16

./network_validation.sh ens34 \
172.16.85.11 \
172.16.88.12 \
172.16.88.13

./network_validation.sh ens36 \
172.16.85.11 \
172.16.87.12 \
172.16.87.13 \
172.16.87.14 \
172.16.85.15 \
172.16.85.16
```

#### On compute

```bash
./network_validation.sh ens33 \
172.16.85.11 \
172.16.85.12 \
172.16.85.13 \
172.16.85.14 \
172.16.85.15 \
172.16.85.16

./network_validation.sh ens35 \
172.16.86.14 \
172.16.86.15 \
172.16.86.16

./network_validation.sh ens36 \
172.16.87.11 \
172.16.87.12 \
172.16.87.13 \
172.16.87.14 \
172.16.87.15 \
172.16.87.16
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
