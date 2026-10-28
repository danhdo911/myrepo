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

Verify Ceph version
```bash
ceph version
```

