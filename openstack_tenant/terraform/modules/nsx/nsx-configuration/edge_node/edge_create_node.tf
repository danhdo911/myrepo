resource "nsxt_edge_transport_node" "edge_node" {

  display_name = var.edge_node_name
  ip_addresses = [var.edge_mgmt_ip]

  standard_host_switch {
    ip_assignment {
      static_ip_pool = var.static_ip_pool_id
    }
    transport_zone_endpoint {
      transport_zone = var.tz_vlan_id
    }
    transport_zone_endpoint {
      transport_zone = var.tz_overlay_id
    }
    host_switch_profile = [var.uplink_host_switch_profile_id]
    pnic {
      device_name = var.edge_uplink_int01
      uplink_name = var.edge_uplinks_profile_uplink_1_name
    }
    pnic {
      device_name = var.edge_uplink_int02
      uplink_name = var.edge_uplinks_profile_uplink_2_name

    }
  }

  deployment_config {
    form_factor = var.deployment_option
    node_user_settings {
      cli_password  = data.vault_kv_secret_v2.vault_vsphere.data["${var.edge_password}"]
      root_password = data.vault_kv_secret_v2.vault_vsphere.data["${var.edge_password}"]
    }
    vm_deployment_config {
      management_network_id = data.vsphere_network.network01.id
      management_port_subnet {
        ip_addresses  = [var.edge_mgmt_ip]
        prefix_length = var.edge_mgmt_prefix
      }
      default_gateway_address = [var.edge_mgmt_gateway]
      data_network_ids        = [data.vsphere_network.network02.id, data.vsphere_network.network02.id]
      compute_id              = data.vsphere_compute_cluster.cluster.id
      storage_id              = data.vsphere_datastore.datastore.id
      vc_id                   = var.compute_manager_id
      # host_id                 = data.vsphere_host.host.id
    }
  }

  node_settings {
    hostname             = var.edge_node_name
    allow_ssh_root_login = true
    enable_ssh           = true
  }
}