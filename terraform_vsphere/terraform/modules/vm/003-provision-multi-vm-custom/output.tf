# output "vms_name" {
#   value = vsphere_virtual_machine.vm[*].name
#   }

# output "vm_ip" {
#   value = vsphere_virtual_machine.vm[*].default_ip_address
# }

# output "vms_info_a" {
#   description = "Output type A"
#   value       = formatlist("name: %s -- ip: %s", vsphere_virtual_machine.vm[*].name, vsphere_virtual_machine.vm[*].default_ip_address)
# }

output "vms_info_b" {
  description = "Output type B"
  value = [for vm in vsphere_virtual_machine.vm : {
    name = vm.name
    ip   = vm.default_ip_address
    mac  = vm.network_interface[0].mac_address
    }
  ]
}

# output "vm_details" {
#   value = { 
#     for vm, details in vsphere_virtual_machine.vm : vm => {
#       ipv4 = details.default_ip_address
#       host_name  = details.name
#       datastore  = details.datastore_id
#       network    = details.network_interface[0].network_id
#     }
#   }
# }

