data "vcd_org_vdc" "vdc1" {
  name = var.org_vdc
}

data "vcd_nsxt_edgegateway" "edgegateway" {
  owner_id = data.vcd_org_vdc.vdc1.id
  name     = var.edgegateway
}

resource "vcd_network_routed_v2" "nsxt-backed" {
  edge_gateway_id = data.vcd_nsxt_edgegateway.edgegateway.id

  name          = var.network_name
  gateway       = var.gateway
  prefix_length = var.prefix_length

  dns1 = var.dns1
  dns2 = var.dns2

  dynamic "static_ip_pool" {
    for_each = var.enable_static_ip_pool ? [1] : []
    content {
      start_address = var.ip_pool_start
      end_address   = var.ip_pool_end
    }
  }
}