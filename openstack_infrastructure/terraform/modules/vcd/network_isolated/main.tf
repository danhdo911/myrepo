resource "vcd_network_isolated_v2" "nsxt-backed" {
  name = var.network_name

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