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

### vCenter Authenticate ###
variable "vcenter_username" {
  type      = string
  sensitive = true
  default   = "vcenter_username"
}

variable "vcenter_password" {
  type      = string
  sensitive = true
  default   = "vcenter_password"
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
variable "vsphere_resource_pool" {}
variable "vsphere_esxi_host" {}
variable "vsphere_folder" {}

### VM Authenticate ###
# variable "vm_remote_type" {}
# variable "vm_user_login" {}
# variable "vm_user_password" {}

### VMs Specific Configurations
variable "vm_template" {}
variable "vm_ssh_public_key" {}
variable "dns_server_list" {
  type = list(string)
}

variable "vm_configs" {
  type = map(object({
    vm_name             = string
    vm_num_cpus         = number
    vm_cores_per_socket = number
    vm_memory           = number
    vm_networks         = list(string)
    vm_int_alias        = list(string)
    vm_ips              = list(string)
    vm_netmask          = list(string)
    vm_mgmt_gateway     = string
    vm_disk_label       = list(string)
    vm_disk_size        = list(number)
    vm_datastore        = string
  }))
}
