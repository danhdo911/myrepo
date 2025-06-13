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

variable "vcenter_username" {}
variable "vcenter_password" {}

### vCenter Authenticate ###
variable "vsphere_user" {
  type      = string
  sensitive = true
  default   = "Administrator@vsphere.local"
}

variable "vsphere_password" {
  type      = string
  sensitive = true
}

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
variable "vsphere_network" {}

### vCenter Appliance Configuration ###
variable "vcenter_fqdn_name" {}
variable "vcenter_username" {}
variable "vcenter_password" {}
variable "vcenter_appliance_username" { default = "root" }
variable "vcenter_domain" {}

variable "vcenter_vm_name" {}
variable "vcenter_disk_provioning" { default = "thin" }
variable "vcenter_deployment_option" {}
variable "local_ovf_path" {}
variable "allow_unverified_ssl_cert" { default = "true" }

variable "cpu_hot_add_enabled" { default = "true" }
variable "cpu_hot_remove_enabled" { default = "true" }
variable "memory_hot_add_enabled" { default = "true" }

variable "vcenter_net_addr_family" {}
variable "vcenter_net_mode" {}
variable "vcenter_ipv4_address" {}
variable "vcenter_net_prefix" {}
variable "vcenter_net_gateway" {}
variable "vcenter_net_dns_server" {}
variable "ntp_server_01" { default = null }
variable "ntp_server_02" { default = null }

variable "deployment_autoconfig" { default = "True" }
variable "ceip_enabled" { default = "False" }
variable "health_check_script" {}
variable "health_check_timeout" { default = 60 }

variable "vcenter_remote_type" { default = "ssh" }
variable "vcenter_remote_timeout" { default = "30m" }








