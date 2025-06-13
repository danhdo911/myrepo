resource "openstack_identity_role_assignment_v3" "role_assignment" {
  group_id   = var.group_id
  project_id = var.project_id
  role_id    = var.role_id
}