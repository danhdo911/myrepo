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

variable "vspher-unverified-ssl" {
  type    = string
  default = true
}

### vSphere Information ###
variable "vsphere_datacenter" {}
variable "vsphere_cluster" {}
# variable "vsphere_datastore" {}
# variable "vsphere_network" {}

### VM Authenticate ###
variable "vm_remote_type" {}
variable "vm_user_login" {}
variable "vm_user_password" {}
variable "vm_user_ssh_public_key" {}

variable "vm_template" {}

### VMs Specific Configurations
variable "vm_configs" {
  type = map(object({
    vm_guest_id         = string
    vm_name             = string
    vm_num_cpus         = number
    vm_cores_per_socket = number
    vm_memory           = number
    vm_networks         = list(string)
    vm_ips              = list(string)
    vm_netmask          = list(string)
    dns_server_list     = list(string)
    vm_mgmt_gateway     = string
    vm_disk01_label     = string
    vm_disk01_size      = number
    vm_disk02_label     = string
    vm_disk02_size      = number
    vm_datastore        = string
    vm_ssh_public_key   = string
  }))
}
