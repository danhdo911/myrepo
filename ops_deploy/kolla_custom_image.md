#

## Build custom image with Ceph 2.20.4 version

Run on Infrastructure node

### Dockerfile

Copy Dockerfile to `workdir/docker-build/Dockerfile`.

Change directory to `workdir/docker-build`.

### cinder-volume

```bash
docker build --pull \
    --build-arg KOLLA_IMAGE=quay.io/openstack.kolla/cinder-volume:2026.1-ubuntu-noble \
    --build-arg SERVICE_USER=cinder
    -t local/cinder-volume:2026.1-ubuntu-noble-ceph20.2.4 \
    .
```

### cinder-backup

```bash
docker build --pull \
    --build-arg KOLLA_IMAGE=quay.io/openstack.kolla/cinder-backup:2026.1-ubuntu-noble \
    --build-arg SERVICE_USER=cinder \
    -t local/cinder-backup:2026.1-ubuntu-noble-ceph20.2.4 \
    .
```

### glance-api

```bash
docker build --pull \
  --build-arg KOLLA_IMAGE=quay.io/openstack.kolla/glance-api:2026.1-ubuntu-noble \
  --build-arg SERVICE_USER=glance \
  -t local/glance-api:2026.1-ubuntu-noble-ceph20.2.4 \
  .
```

### nova-libvirt

```bash
docker build --pull \
  --build-arg KOLLA_IMAGE=quay.io/openstack.kolla/nova-libvirt:2026.1-ubuntu-noble \
  --build-arg SERVICE_USER=root \
  -t local/nova-libvirt:2026.1-ubuntu-noble-ceph20.2.4 \
  .
```

### nova-compute

```bash
docker build --pull \
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
