# resource "vcd_nsxt_firewall" "rule" {
#   edge_gateway_id = var.edge_gateway_id

#   rule {
#     name                 = var.firewall_rule_name
#     direction            = var.direction
#     ip_protocol          = var.ip_protocol
#     action               = var.action
#     enabled              = var.enabled
#     logging              = var.logging
#     source_ids           = var.source_ids
#     destination_ids      = var.destination_ids
#     app_port_profile_ids = var.app_port_profile_ids
#   }
# }

locals {
  id_lookup = merge(
    { for name, profile in data.vcd_nsxt_app_port_profile.app_port_profiles : name => profile.id },
    { for name, group in data.vcd_nsxt_security_group.security_groups : name => group.id },
    { for name, group in data.vcd_nsxt_dynamic_security_group.dynamic_security_groups : name => group.id },
    { for name, set in data.vcd_nsxt_ip_set.ip_sets : name => set.id }
  )
}

resource "vcd_nsxt_firewall" "rule" {
  org             = var.vdc_org_name
  edge_gateway_id = data.vcd_nsxt_edgegateway.edge_gateway.id

  dynamic "rule" {
    for_each = var.rules
    content {
      name                 = rule.value["name"]
      direction            = rule.value["direction"]
      ip_protocol          = rule.value["ip_protocol"]
      action               = rule.value["action"]
      enabled              = lookup(rule.value, "enabled", true)
      logging              = lookup(rule.value, "logging", false)
      source_ids           = try(length(rule.value["source_ids"]), 0) > 0 ? [for name in rule.value["source_ids"] : local.id_lookup[name] if contains(keys(local.id_lookup), name) && name != null && name != ""] : null
      destination_ids      = try(length(rule.value["destination_ids"]), 0) > 0 ? [for name in rule.value["destination_ids"] : local.id_lookup[name] if contains(keys(local.id_lookup), name) && name != null && name != ""] : null
      app_port_profile_ids = try(length(rule.value["app_port_profile_ids"]), 0) > 0 ? [for name in rule.value["app_port_profile_ids"] : local.id_lookup[name] if contains(keys(local.id_lookup), name) && name != null && name != ""] : null
    }
  }
}
