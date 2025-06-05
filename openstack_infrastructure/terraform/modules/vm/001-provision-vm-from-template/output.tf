# output "vms_name" {
#   value = vsphere_virtual_machine.vm[*].name
#   }

# output "vm_ip" {
#   value = vsphere_virtual_machine.vm[*].default_ip_address
# }

output "vms_info" {
  value = formatlist("name: %s -- ip: %s", vsphere_virtual_machine.vm[*].name, vsphere_virtual_machine.vm[*].default_ip_address)
}
