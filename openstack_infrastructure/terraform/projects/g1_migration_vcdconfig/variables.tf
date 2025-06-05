### Hashi Vault ###
variable "vault_address" {
  type        = string
  sensitive   = true
  default     = "https://vault.iij.com.vn"
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

variable "vcd_user" {
  type      = string
  sensitive = true
  default   = "vcd_user"
}
variable "vcd_pass" {
  type      = string
  sensitive = true
  default   = "vcd_pass"
}

variable "nsx_username" {
  type      = string
  sensitive = true
  default   = "nsx_username"
}
variable "nsx_password" {
  type      = string
  sensitive = true
  default   = "nsx_password"
}

### vCD Information ###
variable "vcd_url" { default = "https://iijvndevvcd01.iijvn.local/api" }
variable "vcd_allow_unverified_ssl" { default = true }

variable "vcd_org" { default = "ORG_DANHDO" }
variable "vcd_vdc" { default = "oVDC01-DANHDO" }
variable "edgegateway" { default = "VPC01-DANHDO" }

variable "dns1" { default = null }
variable "dns2" { default = null }

###
variable "dnat_external_port" { default = null }
variable "snat_destination_address" { default = null }

### NSX-T Information ###
variable "nsxt_host" { default = "iijvnnsxmgr-dev.iijvn.local" }
variable "t0_gateway" { default = "T0-VRF-DANH-01" }