resource "openstack_identity_user_v3" "user" {
  default_project_id = var.project_id
  name               = var.user_name
  password           = var.user_password
  description        = var.description

  ignore_change_password_upon_first_use = false
  
  extra = {
    email = var.email
  }
}