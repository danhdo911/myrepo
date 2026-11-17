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
172.16.88.11 \
172.16.88.12 \
172.16.88.13

./network_validation.sh ens36 \
172.16.87.11 \
172.16.87.12 \
172.16.87.13 \
172.16.87.14 \
172.16.87.15 \
172.16.87.16
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

### Setup and run Kolla Bootstrap first

Install kolla-ansible packages and prepare python environment.

```bash
chmod +x kolla_preparation.sh
./kolla_preparation.sh
```

```bash
cp kolla_ansible/globals.yml /etc/kolla/
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

```bash
kolla-ansible bootstrap-servers -i workdir/openstack/multinode
```

### Setup CEPH

[CEPH Installation](./ceph_installation.md).

### Continue preparing Kolla configuration

Kolla configuration including Ceph's keyrings and OpenStack services.

```bash
chmod +x kolla_configure.sh
./kolla_configure.sh
```

### Bug fix: Custom OpenStack services image (Cinder, Glance, Nova)

[Build custom image with Ceph 2.20.4 version](./kolla_custom_image.md)

### Deployment OpenStack with Kolla-Ansible

```bash
kolla-ansible prechecks -i workdir/openstack/multinode --use-test-images
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
openstack segment create compute-ha auto COMPUTE
```

```bash
openstack segment host create <fqdn_compute_nodes> COMPUTE SSH compute-ha
```
