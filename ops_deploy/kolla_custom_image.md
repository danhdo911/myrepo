#

## Build custom image with Ceph 2.20.4 version

Run on Infrastructure node

### Dockerfile

```bash
mkdir -p /root/workdir/docker-build
```

```bash
cp Dockerfile /root/workdir/docker-build/Dockerfile
```

```bash
cd /root/workdir/docker-build
```

### cinder-volume

```bash
docker build --pull \
    --network=host \
    --build-arg KOLLA_IMAGE=quay.io/openstack.kolla/cinder-volume:2026.1-ubuntu-noble \
    --build-arg SERVICE_USER=cinder \
    -t local/cinder-volume:2026.1-ubuntu-noble-ceph20.2.4 \
    .
```

### cinder-backup

```bash
docker build --pull \
    --network=host \
    --build-arg KOLLA_IMAGE=quay.io/openstack.kolla/cinder-backup:2026.1-ubuntu-noble \
    --build-arg SERVICE_USER=cinder \
    -t local/cinder-backup:2026.1-ubuntu-noble-ceph20.2.4 \
    .
```

### glance-api

```bash
docker build --pull \
  --network=host \
  --build-arg KOLLA_IMAGE=quay.io/openstack.kolla/glance-api:2026.1-ubuntu-noble \
  --build-arg SERVICE_USER=glance \
  -t local/glance-api:2026.1-ubuntu-noble-ceph20.2.4 \
  .
```

### nova-libvirt

```bash
docker build --pull \
  --network=host \
  --build-arg KOLLA_IMAGE=quay.io/openstack.kolla/nova-libvirt:2026.1-ubuntu-noble \
  --build-arg SERVICE_USER=root \
  -t local/nova-libvirt:2026.1-ubuntu-noble-ceph20.2.4 \
  .
```

### nova-compute

```bash
docker build --pull \
  --network=host \
  --build-arg KOLLA_IMAGE=quay.io/openstack.kolla/nova-compute:2026.1-ubuntu-noble \
  --build-arg SERVICE_USER=nova \
  -t local/nova-compute:2026.1-ubuntu-noble-ceph20.2.4 \
  .
```

### Transfer image to remote host

```bash
chmod +x ./kolla_custom_image.sh
./kolla_custom_image.sh
```

### Update globals.yml

```bash
# Custom OpenStack images with Ceph 20.2.4 client packages
cinder_volume_image_full: "local/cinder-volume:2026.1-ubuntu-noble-ceph20.2.4"
cinder_backup_image_full: "local/cinder-backup:2026.1-ubuntu-noble-ceph20.2.4"
glance_api_image_full: "local/glance-api:2026.1-ubuntu-noble-ceph20.2.4"
nova_libvirt_image_full: "local/nova-libvirt:2026.1-ubuntu-noble-ceph20.2.4"
nova_compute_image_full: "local/nova-compute:2026.1-ubuntu-noble-ceph20.2.4"
```