resource "nsxt_policy_ip_pool" "ip_pool" {
  display_name = var.ip_pool_name
}

resource "nsxt_policy_ip_pool_static_subnet" "ip_pool_subnet" {
  display_name = var.ip_pool_subnet_name
  pool_path    = nsxt_policy_ip_pool.ip_pool.path
  cidr         = var.ip_pool_cidr

  allocation_range {
    start = var.ip_pool_range_start
    end   = var.ip_pool_range_end
  }
}