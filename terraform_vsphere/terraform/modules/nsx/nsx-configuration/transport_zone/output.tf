output "tz_overlay_id" {
  value = nsxt_policy_transport_zone.overlay_transport_zone.realized_id
}

output "tz_vlan_id" {
  value = nsxt_policy_transport_zone.vlan_transport_zone.realized_id
}