module "ops_vm" {
  source = "../../terraform/modules/vm/005-provision-ops-dev01"

  vsphere_datacenter    = var.vsphere_datacenter
  vsphere_cluster       = var.vsphere_cluster
  vsphere_resource_pool = var.vsphere_resource_pool
  vsphere_esxi_host     = var.vsphere_esxi_host
  vsphere_folder        = var.vsphere_folder

  vm_template       = var.vm_template
  vm_ssh_public_key = var.vm_ssh_public_key
  dns_server_list   = var.dns_server_list

  vm_configs = var.vm_configs
}