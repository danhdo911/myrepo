resource "nsxt_policy_transport_zone" "overlay_transport_zone" {
  display_name   = var.tz_overlay
  transport_type = var.tz_overlay_type
}

resource "nsxt_policy_transport_zone" "vlan_transport_zone" {
  display_name   = var.tz_vlan
  transport_type = var.tz_vlan_type
}