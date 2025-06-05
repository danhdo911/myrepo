resource "openstack_compute_quotaset_v2" "compute_quota" {
  project_id           = var.project_id

  key_pairs            = var.num_keypairs
  ram                  = var.num_ram
  cores                = var.num_cores
  instances            = var.num_instance
  server_groups        = var.num_servergroups
  server_group_members = var.num_servergroup_members
}