resource "openstack_networking_router_v2" "router_1" {
    tenant_id           = var.tenant_id
    name                = var.router_name
    admin_state_up      = var.admin_state_up
    external_network_id = var.external_network_id
    enable_snat         = var.enable_snat

    dynamic external_fixed_ip {
        for_each = var.external_ip_address != "" ? [1] : []
        content {
            subnet_id  = var.external_subnet_id
            ip_address = var.external_ip_address
        }
    }
}
