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
  name          = format("%s%s", data.vsphere_compute_cluster.cluster.name, var.vsphere_resource_pool)
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# vSphere host to deploy the OVA data source
data "vsphere_host" "host" {
  name          = var.vsphere_host
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# vSphere network to connect the VM data source
data "vsphere_network" "network01" {
  name          = var.vsphere_network_01
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network02" {
  name          = var.vsphere_network_02
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

## Local OVF/OVA Source - In the local machine where Terraform is running
data "vsphere_ovf_vm_template" "ovfLocal" {
  name              = var.vcd_vm_name
  disk_provisioning = var.disk_provisioning
  resource_pool_id  = data.vsphere_resource_pool.default.id
  datastore_id      = data.vsphere_datastore.datastore.id
  host_system_id    = data.vsphere_host.host.id
  local_ovf_path    = var.local_ovf_path
  ovf_network_map = {
    "eth0 Network" : data.vsphere_network.network01.id,
    "eth1 Network" : data.vsphere_network.network02.id
  }
}