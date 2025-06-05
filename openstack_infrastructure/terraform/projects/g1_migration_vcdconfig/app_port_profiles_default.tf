### Default Port Profiles: need to define each ports
data "vcd_nsxt_app_port_profile" "tcp_ssh" {
  context_id = data.vcd_org_vdc.vdc1.id

  scope = "SYSTEM"
  name  = "SSH"
}

data "vcd_nsxt_app_port_profile" "tcp_http" {
  context_id = data.vcd_org_vdc.vdc1.id

  scope = "SYSTEM"
  name  = "HTTP"
}

data "vcd_nsxt_app_port_profile" "tcp_https" {
  context_id = data.vcd_org_vdc.vdc1.id

  scope = "SYSTEM"
  name  = "HTTPS"
}

data "vcd_nsxt_app_port_profile" "udp_ike_exchange" {
  context_id = data.vcd_org_vdc.vdc1.id

  scope = "SYSTEM"
  name  = "IKE (Key Exchange)"
}

data "vcd_nsxt_app_port_profile" "udp_nat_traversal" {
  context_id = data.vcd_org_vdc.vdc1.id

  scope = "SYSTEM"
  name  = "IKE (NAT Traversal)"
}