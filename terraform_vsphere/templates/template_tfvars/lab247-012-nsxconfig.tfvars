### Hashi Vault ###
vault_address     = "https://vault.iij.com.vn"
vault_secret_path = "iijvn-ansiblevsphere"
vault_secret_data = "vcsa_lab_247"

vcenter_username     = "vcenter_username"
vcenter_password     = "vcenter_password"
vcenter_thumbprint   = "vcenter_thumbprint"
nsx_username         = "nsx_username"
nsx_general_password = "nsx_general_password"
edge_password        = "nsx_general_password"

### vSphere data ###
vsphere_server         = "192.168.138.247"
vsphere_unverified_ssl = "true"
vsphere_datacenter     = "Auto-DC"
vsphere_cluster        = "ClusterA01"
# vsphere_host           = "192.168.138.249"
vsphere_datastore  = "TESTMIGRATE"
vsphere_network_01 = "vDS-PG-VLAN138"
vsphere_network_02 = "vDS-TRUNK"

### NSX Configuration ###
nsxt_host = "terra-nsx01.dd-iaas.local"

# Compute manager
compute_manager_name   = "dd-vcsa-247"
compute_manager_server = "dd-vcsa-247.dd-iaas.local"

# Transport zones
tz_overlay = "TZ-OVERLAY-TF01"
tz_vlan    = "TZ-VLAN-TF01"

# TEP IP Pool
ip_pool_tep_name        = "TEP-TF01-VL231"
ip_pool_tep_subnet_name = "TEP-TF01-VL231-SUBNET"
ip_pool_tep_range_start = "100.100.231.101"
ip_pool_tep_range_end   = "100.100.231.150"
ip_pool_tep_cidr        = "100.100.231.0/24"

# Edge Uplinks Profile
tep_uplink_profile_name                 = "TEP-Uplinks-Profile"
tep_uplink_profile_transport_vlan       = "0"
tep_uplink_profile_overlay_encap        = "GENEVE"
tep_uplink_profile_uplink_1_name        = "Uplink1"
tep_uplink_profile_uplink_2_name        = "Uplink2"
tep_uplink_profile_uplink_type          = "PNIC"
tep_uplink_profile_policy_teaming       = "LOADBALANCE_SRCID"
tep_uplink_profile_policy_named_teaming = "FAILOVER_ORDER"

# Edge node configuration
deployment_option = "SMALL"
edge_mgmt_prefix  = "24"
edge_mgmt_gateway = "192.168.138.1"

edge_node = {
  edge_node_01 = {
    edge_node_name = "tf-edge-01"
    edge_mgmt_ip   = "192.168.138.237"
  }
  edge_node_02 = {
    edge_node_name = "tf-edge-02"
    edge_mgmt_ip   = "192.168.138.238"
  }
}

