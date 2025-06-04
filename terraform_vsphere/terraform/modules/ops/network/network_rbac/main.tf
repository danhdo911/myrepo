resource "openstack_networking_rbac_policy_v2" "rbac_policy" {
  action        = var.rbac_action
  object_id     = var.object_id
  object_type   = var.object_type
  target_tenant = var.target_tenant
}