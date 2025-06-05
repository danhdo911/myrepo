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

variable "general_password" {
  description = "General password for multiple purposes: nsx admin, nsx cli, nsx audit, nsx grub"
  type        = string
}

variable "vcenter_username" {}
variable "vcenter_password" {}

### vCenter Authenticate ###
variable "vsphere_server" {
  type      = string
  sensitive = true
}

variable "vsphere_unverified_ssl" {
  type    = string
  default = true
}

### vSphere Information ###
variable "vsphere_datacenter" {}
variable "vsphere_cluster" {}
variable "vsphere_host" {}
variable "vsphere_datastore" {}

### NSX Manager Configuration ###
variable "nsx_passwd_0" {
  sensitive = true
  default   = null
}

variable "nsx_cli_passwd_0" {
  sensitive = true
  default   = null
}

variable "nsx_cli_audit_passwd_0" {
  sensitive = true
  default   = null
}

variable "nsx_grub_passwd" {
  sensitive = true
  default   = null
}

variable "local_ovf_path" {}
variable "nsx_vm_name" {}
variable "vsphere_network" {}
variable "disk_provisioning" { default = "thin" }
variable "deployment_option" { default = "extra_small" } # valid deployments are: extra_small, small, medium, large 
variable "nsx_role" { default = "NSX Manager" }          # valid roles are NSX Manager, NSX Global Manager 
variable "nsx_grub_menu_timeout" { default = "5" }
variable "nsx_cli_username" { default = "admin" }
variable "nsx_cli_audit_username" { default = "audit" }
variable "nsx_hostname" {}
variable "nsx_ip_0" {}
variable "nsx_netmask_0" {}
variable "nsx_gateway_0" {}
variable "nsx_dns1_0" {}
variable "nsx_domain_0" {}
variable "nsx_ntp_0" {}
variable "nsx_isSSHEnabled" { default = "True" }
variable "nsx_allowSSHRootLogin" { default = "True" }



