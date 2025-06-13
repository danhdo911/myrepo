data "vault_kv_secret_v2" "vault_vsphere" {
  mount = var.vault_secret_path
  name  = var.vault_secret_data
}

module "ops_vm" {
  source = "./modules/vsphere-vm-test"

  vsphere_datacenter    = var.vsphere_datacenter
  vsphere_cluster       = var.vsphere_cluster
  vsphere_resource_pool = var.vsphere_resource_pool
  vsphere_folder        = var.vsphere_folder

  vm_template       = var.vm_template
  vm_ssh_public_key = var.vm_ssh_public_key
  dns_server_list   = var.dns_server_list

  vm_configs = var.vm_configs
}