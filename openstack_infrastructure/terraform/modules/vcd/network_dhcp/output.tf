output "id" {
  description = "The ID of the created NSX-T Routed Network"
  value       = vcd_nsxt_network_dhcp.pools.id
}
