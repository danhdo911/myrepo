resource "openstack_blockstorage_quotaset_v3" "block_quota" {
  project_id = var.project_id

  volumes              = var.num_volumes
  snapshots            = var.num_snapshots
  gigabytes            = var.total_gigabytes
  per_volume_gigabytes = var.per_volume_gigabytes
  backups              = var.num_backups
  backup_gigabytes     = var.total_backup_gigabytes
  groups               = var.num_groups
}