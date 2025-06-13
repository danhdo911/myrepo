output "vms_info" {
  description = "Output name and IP of all VMs"

  value = [
    for idx in range(length(vsphere_virtual_machine.vm)) : {
      name = vsphere_virtual_machine.vm[idx].name
      ip   = vsphere_virtual_machine.vm[idx].default_ip_address
    }
  ]
}

