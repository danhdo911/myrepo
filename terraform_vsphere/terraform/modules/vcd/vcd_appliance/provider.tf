terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "2.10.0"
    }
  }
}

provider "vault" {
  address          = var.vault_address
  skip_child_token = true
}

provider "vsphere" {
  user                 = data.vault_kv_secret_v2.vault_vsphere.data["${var.vcenter_username}"]
  password             = data.vault_kv_secret_v2.vault_vsphere.data["${var.vcenter_password}"]
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = var.vsphere_unverified_ssl
}