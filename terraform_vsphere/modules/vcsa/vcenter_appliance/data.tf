# Hashi Vault
data "vault_kv_secret_v2" "vault_vsphere" {
  mount = var.vault_secret_path
  name  = var.vault_secret_data
}

## vSphere DC data source
data "vsphere_datacenter" "datacenter" {
  name = var.vsphere_datacenter
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# vSphere resouce pool, leave by default if you have no resource pools
data "vsphere_resource_pool" "default" {
  name          = format("%s%s", data.vsphere_compute_cluster.cluster.name, "/Resources")
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# vSphere host to deploy the OVA data source
data "vsphere_host" "host" {
  name          = var.vsphere_host
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# vSphere network to connect the VM data source
data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_ovf_vm_template" "ovfLocal" {
  name              = var.vcenter_vm_name
  disk_provisioning = var.vcenter_disk_provioning
  deployment_option = var.vcenter_deployment_option
  resource_pool_id  = data.vsphere_resource_pool.default.id
  datastore_id      = data.vsphere_datastore.datastore.id
  host_system_id    = data.vsphere_host.host.id
  local_ovf_path    = var.local_ovf_path
  ovf_network_map = {
    "VM Network" : data.vsphere_network.network.id
  }
}