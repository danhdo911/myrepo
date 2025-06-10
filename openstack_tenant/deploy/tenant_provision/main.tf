################### Project Configurations ####################
module "TENANT_B" {
  source = "../../modules/ops/identity/identity_project"

  project_name = "TENANT_B"
  description  = "CONTRACT SGN001"
}

module "TENANT_B_admin_user" {
  source     = "../../modules/ops/identity/identity_users"
  depends_on = [module.TENANT_B]

  project_id    = module.TENANT_B.id
  user_name     = var.user_name
  user_password = var.user_password
  email         = "${var.user_name}@xyz.com"
}

module "TENANT_B_group" {
  source = "../../modules/ops/identity/identity_group"

  group = "TENANT_B_Group"
}

module "TENANT_B_membership" {
  source     = "../../modules/ops/identity/identity_membership"
  depends_on = [module.TENANT_B_admin_user, module.TENANT_B_group]

  user_id  = module.TENANT_B_admin_user.id
  group_id = module.TENANT_B_group.id
}

module "TENANT_B_role_assignment" {
  source     = "../../modules/ops/identity/identity_role_assignment"
  depends_on = [module.TENANT_B_group, module.TENANT_B]

  group_id   = module.TENANT_B_group.id
  project_id = module.TENANT_B.id
  role_id    = data.openstack_identity_role_v3.role.id
}

module "TENANT_B_quota_blockstorage" {
  source     = "../../modules/ops/quota/quota_blockstorage"
  depends_on = [module.TENANT_B]

  project_id = module.TENANT_B.id
}

module "TENANT_B_quota_compute" {
  source     = "../../modules/ops/quota/quota_compute"
  depends_on = [module.TENANT_B]

  project_id = module.TENANT_B.id
}

module "TENANT_B_quota_network" {
  source     = "../../modules/ops/quota/quota_network"
  depends_on = [module.TENANT_B]

  project_id = module.TENANT_B.id
}

################### Network Configurations ####################
module "public_vlan" {
  source  = "../../modules/ops/network/network_network"
  depends_on = [module.TENANT_B]

  tenant_id = module.TENANT_B.id
  network_name = "TENANT_B_public_vlan"

  external_enabled = true
  network_type     = "vlan"
  physical_network = "physnet3"
  segmentation_id  = 138
}

module "TENANT_B_public_vlan_rbac" {
  source = "../../modules/ops/network/network_rbac"
  depends_on = [module.public_vlan]

  rbac_action   = "access_as_external"
  object_type   = "network"
  object_id     = module.public_vlan.id
  target_tenant = module.TENANT_B.id
}

module "public_vlan_vlan_138" {
  source     = "../../modules/ops/network/network_subnet"
  depends_on = [module.public_vlan]

  network_id  = module.public_vlan.id
  subnet_name = "vlan_138"
  subnet_cidr = "192.168.138.0/24"
  enable_dhcp = false

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
  depends_on = [module.TENANT_B]

  tenant_id = module.TENANT_B.id
  network_name = "TENANT_B_local_app"

}


module "local_app_vlan_172_11_10" {
  source     = "../../modules/ops/network/network_subnet"
  depends_on = [module.local_app]

  network_id  = module.local_app.id
  subnet_name = "vlan_172_11_10"
  subnet_cidr = "172.11.10.0/24"
  enable_dhcp = true

  allocation_pools = [
    {
        allocation_pool_start = "172.11.10.101"
        allocation_pool_end = "172.11.10.150"
    },
  ]
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}

module "local_db" {
  source  = "../../modules/ops/network/network_network"
  depends_on = [module.TENANT_B]

  tenant_id = module.TENANT_B.id
  network_name = "TENANT_B_local_db"

}


module "local_db_vlan_172_11_20" {
  source     = "../../modules/ops/network/network_subnet"
  depends_on = [module.local_db]

  network_id  = module.local_db.id
  subnet_name = "vlan_172_11_20"
  subnet_cidr = "172.11.20.0/24"
  enable_dhcp = false

}


################### Router Configurations ####################
module "TENANT_B_router_1" {
  source     = "../../modules/ops/network/network_router"
  depends_on = [module.public_vlan,module.public_vlan_vlan_138]

  tenant_id           = module.TENANT_B.id
  router_name         = "TENANT_B_router_1"
  external_network_id = module.public_vlan.id
  external_subnet_id  = module.public_vlan_vlan_138.id
  external_ip_address = "192.168.138.248"
}

module "TENANT_B_router_1_local_app_vlan_172_11_10_interface" {
  source = "../../modules/ops/network/network_router_interface"
  depends_on = [module.TENANT_B_router_1]

  router_id = module.TENANT_B_router_1.id
  subnet_id = module.local_app_vlan_172_11_10.id
}
