# CEPH Installation (On Controller01)

## Install packages

```bash
chmod +x ceph_install_packages.sh
./ceph_install_packages.sh
```

## Initial Ceph cluster

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

## Adding hosts to the cluster

Run command to adding nodes to the cluster.

```bash
chmod +x ceph_add_nodes.sh
./ceph_add_nodes.sh.sh
```

Verify all nodes are registered.

```bash
ceph -s
ceph orch host ls
ceph orch device ls --wide
```

## Configuration

Run command to configure MONs and MGRs.

```bash
chmod +x ceph_configure.sh
./ceph_configure.sh
```

Run command to configure OSDs.

```bash
DEPLOY_OSD=true ./ceph_configure.sh
```

Verify OSD deployment:

```bash
ceph orch ps --daemon-type osd
ceph osd tree
ceph osd stat
ceph -s
```

## Create RBD pools for OpenStack services

```bash
chmod +x ./ceph_create_rbd.sh
./ceph_create_rbd.sh
```

## Verify Ceph before 

Verify each components.

```bash
# Cluster health
ceph -s

# RBD pools
ceph osd pool ls detail

# CephX users
ceph auth ls

# Exported files
ls -l output/ceph/
```

Verify RBD access using each exported keyring.

```bash
rbd --id glance -p images ls \
    --keyring output/ceph/ceph.client.glance.keyring

rbd --id cinder -p volumes ls \
    --keyring output/ceph/ceph.client.cinder.keyring

rbd --id cinder -p vms ls \
    --keyring output/ceph/ceph.client.cinder.keyring

rbd --id cinder-backup -p backups ls \
    --keyring output/ceph/ceph.client.cinder-backup.keyring
```
