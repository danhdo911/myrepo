### Flavor

```bash
openstack flavor create --public std_kvm-1c-1g --vcpu 1 --ram 1024 --disk 0 --i
openstack flavor create --public std_kvm-1c-2g --vcpu 1 --ram 2048 --disk 0 --i
openstack flavor create --public std_kvm-2c-2g --vcpu 2 --ram 2048 --disk 0 --i
openstack flavor create --public std_kvm-2c-4g --vcpu 2 --ram 4096 --disk 0 --i
openstack flavor create --public std_kvm-2c-6g --vcpu 2 --ram 6144 --disk 0 --i
openstack flavor create --public std_kvm-2c-8g --vcpu 2 --ram 8192 --disk 0 --i
openstack flavor create --public std_kvm-2c-12g --vcpu 2 --ram 12288 --disk 0 --i
openstack flavor create --public std_kvm-2c-16g --vcpu 2 --ram 16384 --disk 0 --i
openstack flavor create --public std_kvm-4c-4g --vcpu 4 --ram 4096 --disk 0 --i
openstack flavor create --public std_kvm-4c-8g --vcpu 4 --ram 8192 --disk 0 --i
openstack flavor create --public std_kvm-4c-16g --vcpu 4 --ram 16384 --disk 0 --i
openstack flavor create --public std_kvm-4c-24g --vcpu 4 --ram 24576 --disk 0 --i
openstack flavor create --public std_kvm-4c-32g --vcpu 4 --ram 32768 --disk 0 --i
openstack flavor create --public std_kvm-4c-48g --vcpu 4 --ram 49152 --disk 0 --i
openstack flavor create --public std_kvm-6c-6g --vcpu 6 --ram 6144 --disk 0 --i
openstack flavor create --public std_kvm-6c-8g --vcpu 6 --ram 8192 --disk 0 --i
openstack flavor create --public std_kvm-6c-12g --vcpu 6 --ram 12288 --disk 0 --i
openstack flavor create --public std_kvm-6c-16g --vcpu 6 --ram 16384 --disk 0 --i
openstack flavor create --public std_kvm-6c-24g --vcpu 6 --ram 24576 --disk 0 --i
openstack flavor create --public std_kvm-6c-32g --vcpu 6 --ram 32768 --disk 0 --i
openstack flavor create --public std_kvm-8c-8g --vcpu 8 --ram 8192 --disk 0 --i
openstack flavor create --public std_kvm-8c-12g --vcpu 6 --ram 12288 --disk 0 --i
openstack flavor create --public std_kvm-8c-16g --vcpu 8 --ram 16384 --disk 0 --i
openstack flavor create --public std_kvm-8c-16g --vcpu 8 --ram 24576 --disk 0 --i
openstack flavor create --public std_kvm-8c-32g --vcpu 8 --ram 32768 --disk 0 --i
openstack flavor create --public std_kvm-8c-64g --vcpu 8 --ram 65536 --disk 0 --i
openstack flavor create --public std_kvm-12c-16g --vcpu 12 --ram 16384 --disk 0 --i
openstack flavor create --public std_kvm-12c-24g --vcpu 12 --ram 24576 --disk 0 --i
openstack flavor create --public std_kvm-12c-32g --vcpu 12 --ram 32768 --disk 0 --i
openstack flavor create --public std_kvm-12c-64g --vcpu 12 --ram 65536 --disk 0 --i
openstack flavor create --public std_kvm-14c-16g --vcpu 14 --ram 16384 --disk 0 --i
openstack flavor create --public std_kvm-16c-16g --vcpu 16 --ram 16384 --disk 0 --i
openstack flavor create --public std_kvm-16c-32g --vcpu 16 --ram 32768 --disk 0 --i
openstack flavor create --public std_kvm-16c-64g --vcpu 16 --ram 65536 --disk 0 --i
```

### Create QoS Spec

```bash
openstack volume qos create qos-iops-2k --consumer front-end --property total_iops_sec=2000
openstack volume qos create qos-iops-4k --consumer front-end --property total_iops_sec=4000
openstack volume qos create qos-iops-8k --consumer front-end --property total_iops_sec=8000
openstack volume qos create qos-iops-10k --consumer front-end --property total_iops_sec=10000
```

### Associate QoS Spec to Volume Type

```bash
openstack volume qos associate qos-iops-2k ceph-iops-2k
openstack volume qos associate qos-iops-4k ceph-iops-4k
openstack volume qos associate qos-iops-8k ceph-iops-8k
openstack volume qos associate qos-iops-10k ceph-iops-10k
```
