module "router" {
  source     = "../../modules/ops/network/network_router"
  depends_on = [module.network_public_vlan]

  tenant_id           = module.project_tenant_a.project_id
  router_name         = "${var.project_name}_router"
  external_network_id = module.network_public_vlan.id
  external_subnet_id  = module.subnet_public_vlan.id
  external_ip_address = "192.168.138.248"

}