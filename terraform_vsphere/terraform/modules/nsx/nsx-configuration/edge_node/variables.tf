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
variable "vsphere_resource_pool" { default = "/Resources" }
# variable "vsphere_host" {}
variable "vsphere_datastore" {}
variable "vsphere_network_01" {}
variable "vsphere_network_02" {}

variable "edge_password" {}

### Notes: get realized_id from modules output (depend on other modules)
variable "static_ip_pool_id" {}
variable "tz_vlan_id" {}
variable "tz_overlay_id" {}
variable "uplink_host_switch_profile_id" {}
variable "compute_manager_id" {}
##########################

variable "deployment_option" {}
variable "edge_node_name" {}
variable "edge_uplink_int01" { default = "fp-eth0" }
variable "edge_uplinks_profile_uplink_1_name" {}
variable "edge_uplink_int02" { default = "fp-eth1" }
variable "edge_uplinks_profile_uplink_2_name" {}

variable "edge_mgmt_ip" {}
variable "edge_mgmt_prefix" {}
variable "edge_mgmt_gateway" {}