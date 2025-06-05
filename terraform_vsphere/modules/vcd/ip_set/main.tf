resource "vcd_nsxt_ip_set" "ip_set" {
  org             = var.vcd_org
  edge_gateway_id = var.edge_gateway_id

  name         = var.ip_set_name
  description  = var.ip_set_description
  ip_addresses = var.ip_set_subnets
}