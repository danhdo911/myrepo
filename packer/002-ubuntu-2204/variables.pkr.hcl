### vCenter Authenticate ###
variable "vsphere_user" {
  type      = string
  sensitive = true
  default   = ""
}

variable "vsphere_password" {
  type      = string
  sensitive = true
  default   = ""
}

variable "vsphere_server" {
  type      = string
  sensitive = true
}

variable "vspher_unverified_ssl" {
  type    = string
  default = true
}

### vSphere Information ###
variable "vsphere_datacenter" {}
variable "vsphere_cluster" {}
variable "vsphere_datastore" {}
variable "vcenter_folder" {}
variable "resource_pool" {}

### Cloud-init
variable "iso_path" {}
# variable "meta_data_file" { default = "./cloud-init/meta-data" }
# variable "user_data_file" { default = "./cloud-init/user-data" }
variable "cloud_init_files" { default = "./cloud-init/*"}
variable "cd_label" { default = "cidata" }
variable "script_setup" { default = "./scripts/setup-script.sh" }

### VM Configurations ###
variable "vm_version" {}
variable "vm_guest_os_type" {}
variable "convert_to_template" { default = true }
# variable "vm_template" {}
variable "vm_name" {}
variable "vm_num_cpus" {}
variable "vm_cores_per_socket" {}
variable "vm_cpu_hot_plug" { default = true }
variable "vm_memory_hot_plug" { default = true }
variable "vm_memory" {}
variable "vm_disk_controller_type" {}
variable "vm_disk_size" {}
# variable "vm_disk_label" {}
variable "vm_disk_thin_provision" { default = true }
variable "vm_portgroup_name" {}
variable "vm_network_card_type" { default = "vmxnet3" }

### VM Authenticate ###
# variable "vm_remote_type" {}
variable "vm_ssh_port" { default = "22" }
variable "vm_ssh_wait_timeout" { default = "30m" }
variable "vm_user_login" {}
variable "vm_user_password" {}
# variable "vm_user_ssh_public_key" {}
