resource "openstack_identity_group_v3" "group" {
  name        = var.group
  description = var.description
}