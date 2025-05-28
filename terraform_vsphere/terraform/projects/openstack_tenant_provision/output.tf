# output "tenant_info" {
#   value = [
#     {
#       name       = module.tenant_a.name
#       region     = module.tenant_a.region
#       user_admin = var.user_name

#       router          = module.tenant_a_router_1.name
#       external_subnet = module.public_vlan_vlan_138.cidr
#     }
#   ]
# }