locals {
  nsx_passwd_0           = var.nsx_passwd_0 != null ? var.nsx_passwd_0 : data.vault_kv_secret_v2.vault_vsphere.data["${var.general_password}"]
  nsx_cli_passwd_0       = var.nsx_cli_passwd_0 != null ? var.nsx_cli_passwd_0 : data.vault_kv_secret_v2.vault_vsphere.data["${var.general_password}"]
  nsx_cli_audit_passwd_0 = var.nsx_cli_audit_passwd_0 != null ? var.nsx_cli_audit_passwd_0 : data.vault_kv_secret_v2.vault_vsphere.data["${var.general_password}"]
  nsx_grub_passwd        = var.nsx_grub_passwd != null ? var.nsx_grub_passwd : data.vault_kv_secret_v2.vault_vsphere.data["${var.general_password}"]
}