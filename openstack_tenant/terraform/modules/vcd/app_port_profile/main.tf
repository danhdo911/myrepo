resource "vcd_nsxt_app_port_profile" "port_profile" {
  name        = var.port_profile_name
  description = var.port_profile_description

  scope = var.profile_scope

  app_port {
    protocol = var.port_protocol
    port     = var.port_app
  }
}