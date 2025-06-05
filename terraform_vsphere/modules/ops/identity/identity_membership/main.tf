resource "openstack_identity_user_membership_v3" "user_membership" {
  user_id  = var.user_id
  group_id = var.group_id
}