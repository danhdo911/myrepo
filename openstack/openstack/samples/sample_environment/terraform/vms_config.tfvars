### vSphere Config ###
vsphere_server        = "vcenter199.lab.local"
vsphere_datacenter    = "Datacenter"
vsphere_cluster       = "IIJVN-vSAN"
vsphere_resource_pool = "IIJVN-vSAN/Resources/DanhDo/OPS"
vsphere_folder        = "DanhDo/OPS"

### VM Config ###
vm_template       = "ubuntu2204-5-dev"
vm_ssh_public_key = "ansible_public_key"
firmware          = "bios"
dns_server_list   = ["8.8.8.8"]

vm_configs = {
  dd-infra01 = {
    vm_name             = "dd-infra01"
    vm_num_cpus         = 8
    vm_cores_per_socket = 2
    vm_memory           = 8192
    vm_networks         = ["pgv_danh_885_internal"]
    vm_int_alias        = ["ens33"]
    vm_ips              = ["172.16.85.14"]
    vm_netmask          = ["24"]
    vm_gateway          = ["172.16.85.254"]
    vm_disk_label       = ["disk01"]
    vm_disk_size        = [50]
    vm_datastore        = "IIJVN-vSAN"
  },
  dd-ctl01 = {
    vm_name             = "dd-ctl01"
    vm_num_cpus         = 12
    vm_cores_per_socket = 2
    vm_memory           = 32768
    vm_networks         = ["pgv_danh_885_internal", "pgv_danh_888_public", "pgv_danh_887_storage"]
    vm_int_alias        = ["ens33", "ens34", "ens36"]
    vm_ips              = ["172.16.85.11", "172.16.88.11", "172.16.87.11"]
    vm_netmask          = ["24", "24", "24"]
    vm_gateway          = ["172.16.85.254", "172.16.88.254", "172.16.87.254"]
    vm_disk_label       = ["disk01"]
    vm_disk_size        = [50]
    vm_datastore        = "IIJVN-vSAN"
  },
  dd-comp01 = {
    vm_name             = "dd-comp01"
    vm_num_cpus         = 12
    vm_cores_per_socket = 2
    vm_memory           = 32768
    vm_networks         = ["pgv_danh_885_internal", "pgv_danh_886_geneve", "pgv_danh_887_storage"]
    vm_int_alias        = ["ens33", "ens35", "ens36"]
    vm_ips              = ["172.16.85.13", "172.16.86.13", "172.16.87.13"]
    vm_netmask          = ["24", "24", "24"]
    vm_gateway          = ["172.16.85.254", "172.16.86.254", "172.16.87.254"]
    vm_disk_label       = ["disk01"]
    vm_disk_size        = [50]
    vm_datastore        = "IIJVN-vSAN"
  },
  dd-az01gw01 = {
    vm_name             = "dd-az01gw01"
    vm_num_cpus         = 8
    vm_cores_per_socket = 2
    vm_memory           = 8192
    vm_networks         = ["pgv_danh_885_internal", "pgv_danh_886_geneve", "pgc_danh_provider_vlan", "pgc_danh_provider_vlan", "pgc_danh_provider_vlan", "pgc_danh_provider_vlan", "pgc_danh_provider_vlan", "pgc_danh_provider_vlan", "pgc_danh_provider_vlan", "pgc_danh_provider_vlan"]
    vm_int_alias        = ["ens33", "ens35", "eth1", "eth2", "eth3", "eth4", "eth5", "eth6", "eth7", "eth8"]
    vm_ips              = ["172.16.85.12", "172.16.86.12", null, null, null, null, null, null, null, null]
    vm_netmask          = ["24", "24", null, null, null, null, null, null, null, null]
    vm_gateway          = ["172.16.85.254","172.16.86.254", null, null, null, null, null, null, null, null]
    vm_disk_label       = ["disk01"]
    vm_disk_size        = [50]
    vm_datastore        = "IIJVN-vSAN"
  },
}