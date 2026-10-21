### vSphere Config ###
vsphere_server        = "vcenter199.lab.local"
vsphere_datacenter    = "Datacenter"
vsphere_cluster       = "IIJVN-vSAN"
vsphere_resource_pool = "IIJVN-vSAN/Resources/DanhDo/OPS_20251"
vsphere_folder        = "DanhDo/OPS_20251"

### VM Config ###
vm_template       = "ubuntu2404-dev"
vm_ssh_public_key = "ansible_public_key"
firmware          = "bios"
dns_server_list   = ["172.16.85.9"]

vm_configs = {
  dd251infra01 = {
    vm_name              = "dd251infra01"
    vm_num_cpus          = 8
    vm_cores_per_socket  = 2
    vm_memory            = 8192
    vm_networks          = ["pgv_danh_885_internal"]
    vm_int_alias         = ["ens33"]
    vm_ips               = ["172.16.85.21"]
    vm_netmask           = ["24"]
    vm_gateway           = ["172.16.85.254"]
    vm_disk_label        = ["disk01"]
    vm_disk_size         = [50]
    vm_datastore         = "IIJVN-vSAN"
    vm_nested_hv_enabled = true
  },
  dd251ctl01 = {
    vm_name             = "dd251ctl01"
    vm_num_cpus         = 12
    vm_cores_per_socket = 2
    vm_memory           = 32768
    vm_networks         = ["pgv_danh_885_internal", "pgv_danh_888_public", "pgv_danh_887_storage"]
    vm_int_alias        = ["ens33", "ens34", "ens36"]
    vm_ips              = ["172.16.85.22", "172.16.88.22", "172.16.87.22"]
    vm_netmask          = ["24", "24", "24"]
    vm_gateway          = ["172.16.85.254", "172.16.88.254", "172.16.87.254"]
    vm_disk_label       = ["disk01"]
    vm_disk_size        = [50]
    vm_datastore        = "IIJVN-vSAN"
  },
  dd251ctl02 = {
    vm_name             = "dd251ctl02"
    vm_num_cpus         = 12
    vm_cores_per_socket = 2
    vm_memory           = 32768
    vm_networks         = ["pgv_danh_885_internal", "pgv_danh_888_public", "pgv_danh_887_storage"]
    vm_int_alias        = ["ens33", "ens34", "ens36"]
    vm_ips              = ["172.16.85.23", "172.16.88.23", "172.16.87.23"]
    vm_netmask          = ["24", "24", "24"]
    vm_gateway          = ["172.16.85.254", "172.16.88.254", "172.16.87.254"]
    vm_disk_label       = ["disk01"]
    vm_disk_size        = [50]
    vm_datastore        = "IIJVN-vSAN"
  },
  dd251ctl03 = {
    vm_name             = "dd251ctl03"
    vm_num_cpus         = 12
    vm_cores_per_socket = 2
    vm_memory           = 32768
    vm_networks         = ["pgv_danh_885_internal", "pgv_danh_888_public", "pgv_danh_887_storage"]
    vm_int_alias        = ["ens33", "ens34", "ens36"]
    vm_ips              = ["172.16.85.24", "172.16.88.24", "172.16.87.24"]
    vm_netmask          = ["24", "24", "24"]
    vm_gateway          = ["172.16.85.254", "172.16.88.254", "172.16.87.254"]
    vm_disk_label       = ["disk01"]
    vm_disk_size        = [50]
    vm_datastore        = "IIJVN-vSAN"
  },
  dd251comp01 = {
    vm_name              = "dd251comp01"
    vm_num_cpus          = 12
    vm_cores_per_socket  = 2
    vm_memory            = 32768
    vm_networks          = ["pgv_danh_885_internal", "pgv_danh_886_geneve", "pgv_danh_887_storage"]
    vm_int_alias         = ["ens33", "ens35", "ens36"]
    vm_ips               = ["172.16.85.25", "172.16.86.25", "172.16.87.25"]
    vm_netmask           = ["24", "24", "24"]
    vm_gateway           = ["172.16.85.254", "172.16.86.254", "172.16.87.254"]
    vm_disk_label        = ["disk01"]
    vm_disk_size         = [50]
    vm_datastore         = "IIJVN-vSAN"
    vm_nested_hv_enabled = true
  },
  dd251az01gw01 = {
    vm_name             = "dd251az01gw01"
    vm_num_cpus         = 8
    vm_cores_per_socket = 2
    vm_memory           = 8192
    vm_networks         = ["pgv_danh_885_internal", "pgv_danh_886_geneve", "pgc_danh_provider_vlan", "pgc_danh_provider_vlan", "pgc_danh_provider_vlan", "pgc_danh_provider_vlan", "pgc_danh_provider_vlan", "pgc_danh_provider_vlan", "pgc_danh_provider_vlan", "pgc_danh_provider_vlan"]
    vm_int_alias        = ["ens33", "ens35", "eth1", "eth2", "eth3", "eth4", "eth5", "eth6", "eth7", "eth8"]
    vm_ips              = ["172.16.85.26", "172.16.86.26", null, null, null, null, null, null, null, null]
    vm_netmask          = ["24", "24", null, null, null, null, null, null, null, null]
    vm_gateway          = ["172.16.85.254", "172.16.86.254", null, null, null, null, null, null, null, null]
    vm_disk_label       = ["disk01"]
    vm_disk_size        = [50]
    vm_datastore        = "IIJVN-vSAN"
  },
}
