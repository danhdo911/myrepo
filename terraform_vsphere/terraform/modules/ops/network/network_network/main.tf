resource "openstack_networking_network_v2" "network" {
    tenant_id      = var.tenant_id
    name           = var.network_name
    admin_state_up = var.admin_state_up

    shared   = var.shared_enabled
    external = var.external_enabled

    dynamic segments {
        for_each = var.external_enabled ? [1] : []
        content {
            network_type = var.network_type
            physical_network = (var.network_type == "vlan" || var.network_type == "flat") ? var.physical_network : null
            segmentation_id = (var.network_type != "geneve" || var.network_type != "flat") ? var.segmentation_id : null
        }
    }

    tags = var.tags
}