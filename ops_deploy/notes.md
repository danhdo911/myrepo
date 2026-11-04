### Check ceph services

systemctl list-units 'ceph-*.service' --all

### Config allowed cipher

ceph mon set auth_allowed_ciphers aes,aes256k

### OpenStack

Create external network with specify gateway.
No need create stastic route on OVN Router.

Check SNAT on Neutron router

```bash
openstack router show <router-id> -c external_gateway_info
```

Check OVN default route

```bash
docker exec ovn_nb_db \
  ovn-nbctl lr-route-list neutron-<router_id>
```

Check NAT rules

```bash
docker exec ovn_nb_db \
  ovn-nbctl lr-nat-list neutron-<router_id>
```

### Maintenance

#### Compute nodes

```bash
COMPUTE_NODE="dd261comp02.dd-iaas.local"
```

From OpenStack side:

```bash
openstack compute service set \
  --disable \
  --disable-reason "Scheduled maintenance - Enable virtualization" \
  "$COMPUTE_NODE" nova-compute
```

```bash
openstack server list \
  --all-projects \
  --host "$COMPUTE_NODE" \
  --long
```

From Ceph side:

```bash
CEPH_NODE="dd261comp02"
```

```bash
ceph -s
ceph health detail
ceph osd tree
ceph orch ps --hostname "$CEPH_NODE"
```

```bash
ceph osd ok-to-stop <osd_id>

```bash
ceph osd set-group noout "$CEPH_NODE"
```