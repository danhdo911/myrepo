output "tenant_info" {
  value = [
    {
      name   = module.project_tenant_a.project_name
      region = module.project_tenant_a.region
      user_admin  = var.user_name
    }
  ]
}