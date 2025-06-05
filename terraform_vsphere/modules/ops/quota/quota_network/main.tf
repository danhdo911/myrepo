resource "openstack_networking_quota_v2" "network_quota" {
  project_id          = var.project_id

  network             = var.num_networks
  subnet              = var.num_subnet
  subnetpool          = var.num_subnetpool
  port                = var.num_ports
  router              = var.num_router
  floatingip          = var.num_floatingips
  security_group      = var.num_securitygroup
  security_group_rule = var.num_securitygroup_rule
  rbac_policy         = var.num_rbac_policy
}