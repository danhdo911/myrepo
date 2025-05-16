resource "nsxt_compute_manager" "compute_manager" {

  display_name = var.compute_manager_name
  server       = var.compute_manager_server

  credential {
    username_password_login {
      username   = data.vault_kv_secret_v2.vault_vsphere.data["${var.vcenter_username}"]
      password   = data.vault_kv_secret_v2.vault_vsphere.data["${var.vcenter_password}"]
      thumbprint = data.vault_kv_secret_v2.vault_vsphere.data["${var.vcenter_thumbprint}"]
    }
  }
  origin_type = var.compute_manager_origin_type
}