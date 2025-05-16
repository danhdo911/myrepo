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

resource "vcd_nsxt_firewall" "rule" {
  org             = var.vcd_org
  edge_gateway_id = var.edge_gateway_id

  dynamic "rule" {
    for_each = var.rules
    content {
      name                 = rule.value.name
      direction            = rule.value.direction
      ip_protocol          = rule.value.ip_protocol
      action               = rule.value.action
      enabled              = rule.value.enabled
      logging              = rule.value.logging
      source_ids           = rule.value.source_ids
      destination_ids      = rule.value.destination_ids
      app_port_profile_ids = rule.value.app_port_profile_ids
    }
  }
}
