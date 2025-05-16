resource "vcd_nsxt_network_dhcp" "pools" {
  org = var.vcd_org
  org_network_id = var.org_network_id

  dynamic pool {
    for_each = var.dhcp_pool_start != "" ? [1] : []
    content {
      start_address = var.dhcp_pool_start
      end_address   = var.dhcp_pool_end
    }
  }
}