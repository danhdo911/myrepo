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
variable "vsphere_datastore" {}

### VM Configurations ###
variable "vm_numbers" {
  type        = number
  description = "Number of VMs to provision"
}

variable "vm_template" {}
variable "vm_name" {}
variable "vm_num_cpus" {}
variable "vm_cores_per_socket" {}
variable "vm_memory" {}
variable "vm_disk_label" {}
variable "vm_disk_size" {}
variable "vm_guest_id" {}
variable "vm_portgroup_name" {}

### VM Authenticate ###
variable "vm_remote_type" {}
variable "vm_user_login" {}
variable "vm_user_password" {}
variable "vm_user_ssh_public_key" {}
