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
variable "vcenter_thumbprint" {}
variable "nsx_username" {}
variable "nsx_general_password" {}
variable "edge_password" {}

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

### NSX-T Configuration ###
variable "nsxt_host" {}

variable "compute_manager_name" {}
variable "compute_manager_server" {}
variable "compute_manager_origin_type" { default = "vCenter" }

variable "tz_overlay" {}
variable "tz_overlay_type" { default = "OVERLAY_STANDARD" }
variable "tz_vlan" {}
variable "tz_vlan_type" { default = "VLAN_BACKED" }

variable "ip_pool_tep_name" {}
variable "ip_pool_tep_subnet_name" {}
variable "ip_pool_tep_range_start" {}
variable "ip_pool_tep_range_end" {}
variable "ip_pool_tep_cidr" {}

variable "tep_uplink_profile_name" {}
variable "tep_uplink_profile_transport_vlan" {}
variable "tep_uplink_profile_overlay_encap" {}
variable "tep_uplink_profile_uplink_1_name" {}
variable "tep_uplink_profile_uplink_2_name" {}
variable "tep_uplink_profile_uplink_type" {}
variable "tep_uplink_profile_policy_teaming" {
  description = "Default TeamingPolicy associated with this UplinkProfile"
}
variable "tep_uplink_profile_policy_named_teaming" {
  description = "List of named uplink teaming policies that can be used by logical switches."
}

variable "deployment_option" {}
variable "edge_uplink_int01" { default = "fp-eth0" }
variable "edge_uplink_int02" { default = "fp-eth1" }
variable "edge_mgmt_prefix" {}
variable "edge_mgmt_gateway" {}

# variable "edge_node_01_name" {}
# variable "edge_node_01_mgmt_ip" {}
# variable "edge_node_02_name" {}
# variable "edge_node_02_mgmt_ip" {}

variable "edge_node" {
  type = map(object({
    edge_node_name = string
    edge_mgmt_ip   = string
  }))
}