module "network_local_01" {
  source     = "../../modules/ops/network/network_network"
  depends_on = [module.project_tenant_a]

  tenant_id    = module.project_tenant_a.project_id
  network_name = "${var.project_name}_local_01"
}

module "subnet_local_01" {
  source     = "../../modules/ops/network/network_subnet"
  depends_on = [module.network_local_01]

  network_id  = module.network_local_01.id
  subnet_name = "local-vlan-172-10"
  subnet_cidr = "172.10.10.0/24"
}

module "network_local_02" {
  source     = "../../modules/ops/network/network_network"
  depends_on = [module.project_tenant_a]

  tenant_id    = module.project_tenant_a.project_id
  network_name = "${var.project_name}_local_02"
}

module "subnet_local_02" {
  source     = "../../modules/ops/network/network_subnet"
  depends_on = [module.network_local_02]

  network_id  = module.network_local_02.id
  subnet_name = "local-vlan-172-20"
  subnet_cidr = "172.10.20.0/24"

  enable_dhcp = true
  allocation_pools = [
    {
      allocation_pool_start = "172.10.20.11"
      allocation_pool_end   = "172.10.20.20"
    },
    {
      allocation_pool_start = "172.10.20.51"
      allocation_pool_end   = "172.10.20.60"
    }
  ]
}

module "network_public_vlan" {
  source     = "../../modules/ops/network/network_network"
  depends_on = [module.project_tenant_a]

  tenant_id        = module.project_tenant_a.project_id
  network_name     = "${var.project_name}_public_vlan"
  external_enabled = true

  network_type     = "vlan"
  physical_network = "physnet2"
  segmentation_id  = 138
}

module "subnet_public_vlan" {
  source     = "../../modules/ops/network/network_subnet"
  depends_on = [module.network_public_vlan]

  network_id  = module.network_public_vlan.id
  subnet_name = "vlan-138"
  subnet_cidr = "192.168.138.0/24"

  enable_dhcp = true
  allocation_pools = [
    {
      allocation_pool_start = "192.168.138.248"
      allocation_pool_end   = "192.168.138.249"
    }
  ]

  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}
