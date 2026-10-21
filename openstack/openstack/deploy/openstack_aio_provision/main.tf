module "ops_vm" {
  # source = "../../terraform/modules/vm/005-provision-ops-dev"
  source = "../../terraform/modules/vm/005-provision-ops-dev-route"

  vsphere_datacenter    = var.vsphere_datacenter
  vsphere_cluster       = var.vsphere_cluster
  vsphere_resource_pool = var.vsphere_resource_pool
  vsphere_folder        = var.vsphere_folder

  vm_template       = var.vm_template
  firmware          = var.firmware
  vm_user_login     = data.vault_kv_secret_v2.vault_vsphere.data["${var.vm_user_login}"]
  vm_user_password  = data.vault_kv_secret_v2.vault_vsphere.data["${var.vm_user_password}"]
  vm_ssh_public_key = data.vault_kv_secret_v2.vault_vsphere.data["${var.vm_ssh_public_key}"]
  dns_server_list   = var.dns_server_list

  vm_configs = var.vm_configs
}
