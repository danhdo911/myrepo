# Hashi Vault
data "vault_kv_secret_v2" "vault_vsphere" {
  mount = var.vault_secret_path
  name  = var.vault_secret_data
}