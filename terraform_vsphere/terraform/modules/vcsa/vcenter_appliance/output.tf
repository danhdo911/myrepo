output "vcenter_ip" {
  value       = vsphere_virtual_machine.vcenter_appliance.default_ip_address
  description = "vCenter IP address"
}

# output "vcenter_fqdn" {
#   value       = vsphere_virtual_machine.vcenter_appliance.v
#   description = "vCenter FQDN"
# }

# output "vcenter_user" {
#   value       = module.vcenter_provision.vcenter_user
#   description = "SSO user that was created during the vCenter provisioning"
# }

# output "vcenter_password" {
#   value       = module.vcenter_provision.vcenter_password
#   description = "SSO user password that was set during the vCenter provisioning"
# }

# output "vcenter_root_user" {
#   value       = "root"
#   description = "Username for the local root user"
# }

# output "vcenter_root_password" {
#   value       = module.vcenter_provision.vcenter_root_password
#   description = "Password for the local root user"
# }