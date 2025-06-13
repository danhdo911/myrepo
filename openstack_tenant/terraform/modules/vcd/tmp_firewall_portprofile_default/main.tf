data "vcd_org_vdc" "vdc1" {
  org  = var.vcd_org
  name = var.vcd_vdc
}

locals {
  profile_map = { for name in var.names : name => name }
}

data "vcd_nsxt_app_port_profile" "defaults" {
  context_id = data.vcd_org_vdc.vdc1.id

  scope = "SYSTEM"
  name  = each.value
}

output "ids" {
  description = "List of fetched app port profile IDs"
  value       = [for profile in data.vcd_nsxt_app_port_profile.defaults : profile.id]
}
