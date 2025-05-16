terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "4.6.0"
    }
    nsxt = {
      source  = "vmware/nsxt"
      version = "3.8.0"
    }
  }
}