### Hashi Vault ###
variable "vault_address" {
  type        = string
  sensitive   = true
  description = "Store all credentials"
}

variable "vault_secret_path" {
  type      = string
  sensitive = true
}

variable "vault_secret_data" {
  type      = string
  sensitive = true
}

variable "vcenter_username" {}
variable "vcenter_password" {}
variable "vcenter_thumbprint" {}

variable "compute_manager_name" {}
variable "compute_manager_server" {}
variable "compute_manager_origin_type" { default = "vCenter" }