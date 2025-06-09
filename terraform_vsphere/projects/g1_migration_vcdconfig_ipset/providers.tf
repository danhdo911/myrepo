terraform {
  required_providers {
    # vault = {
    #   source  = "hashicorp/vault"
    #   version = "4.6.0"
    # }
    vcd = {
      source = "vmware/vcd"
      # version = "3.14.1"
    }
    # nsxt = {
    #   source  = "vmware/nsxt"
    #   version = "3.8.0"
    # }
  }
}

# provider "vault" {
#   address          = var.vault_address
#   skip_child_token = true
# }

# provider "vcd" {
#   user                 = data.vault_kv_secret_v2.vault_vcd.data["${var.vcd_user}"]
#   password             = data.vault_kv_secret_v2.vault_vcd.data["${var.vcd_pass}"]
#   auth_type            = "integrated"
#   org                  = var.vcd_org
#   vdc                  = var.vcd_vdc
#   url                  = var.vcd_url
#   allow_unverified_ssl = var.vcd_allow_unverified_ssl
# }

provider "vcd" {
  user                 = "none"
  password             = "none"
  auth_type            = "api_token"
  api_token            = var.api_token
  org                  = var.vcd_org
  vdc                  = var.vcd_vdc
  url                  = var.vcd_url
  allow_unverified_ssl = var.vcd_allow_unverified_ssl
}

# provider "nsxt" {
#   username             = data.vault_kv_secret_v2.vault_vcd.data["${var.nsx_username}"]
#   password             = data.vault_kv_secret_v2.vault_vcd.data["${var.nsx_password}"]
#   host                 = var.nsxt_host
#   allow_unverified_ssl = true
#   max_retries          = 3
# }