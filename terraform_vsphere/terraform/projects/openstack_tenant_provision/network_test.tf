module "public_vlan" {
    source  = "../../modules/ops/network/network_network"
    depends_on = [module.tenant_a]

    tenant_id = module.tenant_a.id
    network_name = "tenant_a_public_vlan"

    external_enabled = true
    network_type     = "vlan"
    physical_network = "physnet2"
    segmentation_id  = 138
}

module "public_vlan_vlan_138" {
  source     = "../../modules/ops/network/network_subnet"
  depends_on = [module.public_vlan]

  network_id  = module.public_vlan.id
  subnet_name = "vlan_138"
  subnet_cidr = "192.168.138.0/24"

  enable_dhcp = true
  allocation_pools = [
    {
        allocation_pool_start = "192.168.138.248"
        allocation_pool_end = "192.168.138.249"
    },
  ]
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}

module "local_app" {
    source  = "../../modules/ops/network/network_network"
    depends_on = [module.tenant_a]

    tenant_id = module.tenant_a.id
    network_name = "tenant_a_local_app"

}

module "local_app_vlan_172_10" {
  source     = "../../modules/ops/network/network_subnet"
  depends_on = [module.local_app]

  network_id  = module.local_app.id
  subnet_name = "vlan_172_10"
  subnet_cidr = "172.10.10.0/24"

  enable_dhcp = true
  allocation_pools = [
    {
        allocation_pool_start = "172.10.10.11"
        allocation_pool_end = "172.10.10.20"
    },
    {
        allocation_pool_start = "172.10.10.101"
        allocation_pool_end = "172.10.10.120"
    },
  ]
}

module "local_db" {
    source  = "../../modules/ops/network/network_network"
    depends_on = [module.tenant_a]

    tenant_id = module.tenant_a.id
    network_name = "tenant_a_local_db"

}

module "local_db_vlan_172_20" {
  source     = "../../modules/ops/network/network_subnet"
  depends_on = [module.local_db]

  network_id  = module.local_db.id
  subnet_name = "vlan_172_20"
  subnet_cidr = "172.10.20.0/24"

}

module "local_db_vlan_172_21" {
  source     = "../../modules/ops/network/network_subnet"
  depends_on = [module.local_db]

  network_id  = module.local_db.id
  subnet_name = "vlan_172_21"
  subnet_cidr = "172.10.21.0/24"

}

