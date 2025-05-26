module "project_tenant_a" {
  source = "../../modules/ops/identity/identity_project"

  project_name = var.project_name
}

module "create_user" {
  source     = "../../modules/ops/identity/identity_users"
  depends_on = [module.project_tenant_a]

  project_id    = module.project_tenant_a.project_id
  user_name     = var.user_name
  user_password = var.user_password
  email         = "${var.user_name}@${var.domain}"
}

module "create_group" {
  source = "../../modules/ops/identity/identity_group"

  group = "${var.project_name}-Group"
}

module "membership" {
  source     = "../../modules/ops/identity/identity_membership"
  depends_on = [module.create_user, module.create_group]

  user_id  = module.create_user.id
  group_id = module.create_group.id
}

module "role_assignment" {
  source     = "../../modules/ops/identity/identity_role_assignment"
  depends_on = [module.create_group, module.project_tenant_a]

  group_id   = module.create_group.id
  project_id = module.project_tenant_a.project_id
  role_id    = data.openstack_identity_role_v3.admin.id
}

module "quota_blockstorage" {
  source     = "../../modules/ops/quota/quota_blockstorage"
  depends_on = [module.project_tenant_a]

  project_id = module.project_tenant_a.project_id
}

module "quota_compute" {
  source     = "../../modules/ops/quota/quota_compute"
  depends_on = [module.project_tenant_a]

  project_id = module.project_tenant_a.project_id
}

module "quota_network" {
  source     = "../../modules/ops/quota/quota_network"
  depends_on = [module.project_tenant_a]

  project_id = module.project_tenant_a.project_id
}