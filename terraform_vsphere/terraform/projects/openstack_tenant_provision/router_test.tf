module "tenant_a_router_1" {
  source     = "../../modules/ops/network/network_router"
  depends_on = [module.public_vlan,module.public_vlan_vlan_138]

  tenant_id           = module.tenant_a.id
  router_name         = "tenant_a_router_1"
  external_network_id = module.public_vlan.id
  external_subnet_id  = module.public_vlan_vlan_138.id
  external_ip_address = "192.168.138.248"
}

module "tenant_a_router_1_local_app_vlan_172_10_interface" {
  source = "../../modules/ops/network/network_router_interface"
  depends_on = [module.tenant_a_router_1]

  router_id = module.tenant_a_router_1.id
  subnet_id = module.local_app_vlan_172_10.id
}