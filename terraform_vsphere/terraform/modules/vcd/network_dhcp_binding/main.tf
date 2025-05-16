resource "vcd_nsxt_network_dhcp_binding" "binding" {
  org = var.vcd_org
  org_network_id = var.org_dhcp_id

  name         = var.name
  description  = var.description
  binding_type = var.binding_type
  ip_address   = var.ip_address
  lease_time   = var.lease_time
  mac_address  = var.mac_address
  dns_servers  = var.dns_servers
}