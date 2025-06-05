module "compute_manager" {
  source = "../modules/020-nsx-configuration/compute_manager"

  vault_address     = var.vault_address
  vault_secret_path = var.vault_secret_path
  vault_secret_data = var.vault_secret_data

  vcenter_username   = var.vcenter_username
  vcenter_password   = var.vcenter_password
  vcenter_thumbprint = var.vcenter_thumbprint

  compute_manager_name        = var.compute_manager_name
  compute_manager_server      = var.compute_manager_server
  compute_manager_origin_type = var.compute_manager_origin_type
}

module "transport_zone_01" {
  source = "../modules/020-nsx-configuration/transport_zone"

  tz_overlay = var.tz_overlay
  tz_vlan    = var.tz_vlan
}

module "ip_pool_tep" {
  source = "../modules/020-nsx-configuration/ip_pool"

  ip_pool_name        = var.ip_pool_tep_name
  ip_pool_cidr        = var.ip_pool_tep_cidr
  ip_pool_subnet_name = var.ip_pool_tep_subnet_name
  ip_pool_range_start = var.ip_pool_tep_range_start
  ip_pool_range_end   = var.ip_pool_tep_range_end
}

module "tep_uplink_profile" {
  source = "../modules/020-nsx-configuration/uplink_profile"

  uplink_profile_name                 = var.tep_uplink_profile_name
  uplink_profile_transport_vlan       = var.tep_uplink_profile_transport_vlan
  uplink_profile_overlay_encap        = var.tep_uplink_profile_overlay_encap
  uplink_profile_uplink_1_name        = var.tep_uplink_profile_uplink_1_name
  uplink_profile_uplink_2_name        = var.tep_uplink_profile_uplink_2_name
  uplink_profile_uplink_type          = var.tep_uplink_profile_uplink_type
  uplink_profile_policy_teaming       = var.tep_uplink_profile_policy_teaming
  uplink_profile_policy_named_teaming = var.tep_uplink_profile_policy_named_teaming
}

module "edge_node" {
  source = "../modules/020-nsx-configuration/edge_node"

  depends_on = [
    module.compute_manager,
    module.transport_zone_01,
    module.ip_pool_tep,
    module.tep_uplink_profile
  ]

  vault_address     = var.vault_address
  vault_secret_path = var.vault_secret_path
  vault_secret_data = var.vault_secret_data

  edge_password = var.edge_password

  vsphere_server        = var.vsphere_resource_pool
  vsphere_datacenter    = var.vsphere_datacenter
  vsphere_cluster       = var.vsphere_cluster
  vsphere_resource_pool = var.vsphere_resource_pool
  vsphere_datastore     = var.vsphere_datastore
  vsphere_network_01    = var.vsphere_network_01
  vsphere_network_02    = var.vsphere_network_02

  static_ip_pool_id             = module.ip_pool_tep.static_ip_pool_id
  tz_vlan_id                    = module.transport_zone_01.tz_vlan_id
  tz_overlay_id                 = module.transport_zone_01.tz_overlay_id
  uplink_host_switch_profile_id = module.tep_uplink_profile.tep_uplink_profile_id
  compute_manager_id            = module.compute_manager.compute_manager_id

  deployment_option                  = var.deployment_option
  edge_mgmt_prefix                   = var.edge_mgmt_prefix
  edge_mgmt_gateway                  = var.edge_mgmt_gateway
  edge_uplinks_profile_uplink_1_name = var.tep_uplink_profile_uplink_1_name
  edge_uplinks_profile_uplink_2_name = var.tep_uplink_profile_uplink_2_name

  # Provision multiple Edge node
  for_each       = var.edge_node
  edge_node_name = each.value.edge_node_name
  edge_mgmt_ip   = each.value.edge_mgmt_ip
}