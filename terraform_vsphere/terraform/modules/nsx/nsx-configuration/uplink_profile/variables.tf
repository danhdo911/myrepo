variable "uplink_profile_name" {}
variable "uplink_profile_transport_vlan" {}
variable "uplink_profile_overlay_encap" {}
variable "uplink_profile_uplink_1_name" {}
variable "uplink_profile_uplink_2_name" {}
variable "uplink_profile_uplink_type" {}
variable "uplink_profile_policy_teaming" {
  description = "Default TeamingPolicy associated with this UplinkProfile"
}
variable "uplink_profile_policy_named_teaming" {
  description = "List of named uplink teaming policies that can be used by logical switches."
}