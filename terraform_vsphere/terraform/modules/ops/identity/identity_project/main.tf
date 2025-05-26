resource "openstack_identity_project_v3" "project" {
  name        = var.project_name
  description = var.project_description
  enabled     = var.project_enabled
}