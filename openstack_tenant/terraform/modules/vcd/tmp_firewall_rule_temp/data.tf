#Create the Datacenter Group data source
data "vcd_vdc_group" "dcgroup" {
  org  = var.vdc_org_name
  name = var.vdc_group_name
}

# Create the NSX-T Edge Gateway data source
data "vcd_nsxt_edgegateway" "edge_gateway" {
  org      = var.vdc_org_name
  owner_id = data.vcd_vdc_group.dcgroup.id
  name     = var.vdc_edge_name
}

# Create the NSX-T Data Center Edge Gateway Firewall data source
data "vcd_nsxt_firewall" "edge_fw" {
  org             = var.vdc_org_name
  edge_gateway_id = data.vcd_nsxt_edgegateway.edge_gateway.id
}

data "vcd_nsxt_app_port_profile" "app_port_profiles" {
  org      = var.vdc_org_name
  for_each = var.app_port_profiles
  name     = each.key
  scope    = each.value
}

data "vcd_nsxt_ip_set" "ip_sets" {
  org             = var.vdc_org_name
  for_each        = toset(var.ip_set_names)
  edge_gateway_id = data.vcd_nsxt_edgegateway.edge_gateway.id
  name            = each.value
}

data "vcd_nsxt_dynamic_security_group" "dynamic_security_groups" {
  org          = var.vdc_org_name
  for_each     = toset(var.dynamic_security_group_names)
  vdc_group_id = data.vcd_vdc_group.dcgroup.id
  name         = each.value
}

data "vcd_nsxt_security_group" "security_groups" {
  org             = var.vdc_org_name
  for_each        = toset(var.security_group_names)
  edge_gateway_id = data.vcd_nsxt_edgegateway.edge_gateway.id
  name            = each.value
}