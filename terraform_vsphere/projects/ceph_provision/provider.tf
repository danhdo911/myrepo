terraform {
  required_providers {
    vsphere = {
      source = "vmware/vsphere"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "4.6.0"
    }
  }
}

provider "vsphere" {
  user                 = data.vault_kv_secret_v2.vault_vsphere.data["${var.vcenter_username}"]
  password             = data.vault_kv_secret_v2.vault_vsphere.data["${var.vcenter_password}"]
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = var.vsphere_unverified_ssl
}

provider "vault" {
  skip_child_token = true
}

data "vault_kv_secret_v2" "vault_vsphere" {
  mount = var.vault_secret_path
  name  = var.vault_secret_data
}