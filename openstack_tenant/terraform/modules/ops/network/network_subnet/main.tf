resource "openstack_networking_subnet_v2" "subnet" {
    network_id  = var.network_id
    name        = var.subnet_name
    cidr        = var.subnet_cidr
    ip_version  = var.ip_version
    enable_dhcp = var.enable_dhcp

    dynamic allocation_pool {
    for_each = var.allocation_pools != null ? var.allocation_pools : []
        content {
            start = allocation_pool.value.allocation_pool_start
            end   = allocation_pool.value.allocation_pool_end
        }
    }

    dns_nameservers = var.dns_nameservers != "" ? var.dns_nameservers : null
}