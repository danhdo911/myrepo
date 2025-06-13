resource "vcd_nsxt_nat_rule" "nat" {
  org             = var.vcd_org
  edge_gateway_id = var.edge_gateway_id

  name        = var.rule_name
  rule_type   = var.rule_type
  description = var.description

  external_address         = var.external_address
  internal_address         = var.internal_address
  app_port_profile_id      = var.app_port_profile_id
  dnat_external_port       = var.dnat_external_port
  snat_destination_address = var.snat_destination_address
  logging                  = var.enabled_logging
  firewall_match           = var.firewall_match
  priority                 = var.priority
}