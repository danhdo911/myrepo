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

### vSphere Information ###
variable "vsphere_server" {
  type      = string
  sensitive = true
}

variable "vsphere_unverified_ssl" {
  type    = string
  default = true
}

variable "vsphere_datacenter" {}
variable "vsphere_cluster" {}
variable "vsphere_resource_pool" { default = "/Resources" }
variable "vsphere_host" {}
variable "vsphere_datastore" {}

variable "local_ovf_path" {}
variable "vcd_vm_name" {}
variable "vsphere_network_01" {}
variable "vsphere_network_02" {}
variable "disk_provisioning" { default = "thin" }
variable "deployment_option" { default = "primary-small" }

### vCD Configurations ###
variable "ntp_server" {}
variable "varoot_password" {}
variable "expire_root_password" {}
variable "enable_ssh" {}
variable "routes0" {}
variable "routes1" {}
variable "gateway" {}
variable "domain" {}
variable "searchpath" {}
variable "dns_server" {}
variable "ip0" {}
variable "netmask0" {}
variable "ip1" {}
variable "netmask1" {}
variable "ceip_enabled" {}
variable "nfs_mount" {}
variable "admin_email" {}
variable "admin_fname" {}
variable "admin_pwd" {}
variable "admin_uname" {}
variable "db_pwd" {}
variable "installation_id" {}
variable "sys_name" {}
variable "org_provider" { default = "system" }

variable "scripts_path" { default = "../../scripts/" }

variable "wait_for_ssh_script" {}

variable "vcd_api_version" {}
variable "health_check_script" {}
variable "health_check_timeout" { default = 30 }

variable "vcd_remote_type" { default = "ssh" }
variable "vcd_remote_user" { default = "root" }
variable "vcd_remote_timeout" { default = "30m" }
variable "vcd_tail_cell_log_script" {}