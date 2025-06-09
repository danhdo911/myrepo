# ### Hashi Vault
# data "vault_kv_secret_v2" "vault_vcd" {
#   mount = var.vault_secret_path
#   name  = var.vault_secret_data
# }
### oVDC and Egde Gateway
data "vcd_org_vdc" "vdc1" {
  name = var.vcd_vdc
}

data "vcd_nsxt_edgegateway" "edgegateway" {
  owner_id = data.vcd_org_vdc.vdc1.id
  name     = var.edgegateway
}

# ### NSX-T
# data "nsxt_policy_tier0_gateway" "gw" {
#   display_name = var.t0_gateway
# }