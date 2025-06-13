resource "nsxt_policy_uplink_host_switch_profile" "uplink_host_switch_profile" {
  display_name = var.uplink_profile_name

  transport_vlan = var.uplink_profile_transport_vlan
  overlay_encap  = var.uplink_profile_overlay_encap

  teaming {
    active {
      uplink_name = var.uplink_profile_uplink_1_name
      uplink_type = var.uplink_profile_uplink_type
    }
    active {
      uplink_name = var.uplink_profile_uplink_2_name
      uplink_type = var.uplink_profile_uplink_type
    }
    policy = var.uplink_profile_policy_teaming
  }
  named_teaming {
    active {
      uplink_name = var.uplink_profile_uplink_1_name
      uplink_type = var.uplink_profile_uplink_type
    }
    policy = var.uplink_profile_policy_named_teaming
    name   = var.uplink_profile_uplink_1_name
  }
  named_teaming {
    active {
      uplink_name = var.uplink_profile_uplink_2_name
      uplink_type = var.uplink_profile_uplink_type
    }
    policy = var.uplink_profile_policy_named_teaming
    name   = var.uplink_profile_uplink_2_name
  }
}