output "vms_info" {
  description = "VM Network Details: Port Group, IP, Gateway, MAC, and Alias"
  value = {
    for vm_key, vm in vsphere_virtual_machine.vm :
    vm_key => {
      name = vm.name
      ip = vm.default_ip_address
      # networks = [
      #   for index in range(length(vm.network_interface)) : {
      #     port_group = var.vm_configs[vm_key].vm_networks[index]
      #     alias_name = (
      #       index > 0 # Exclude first network (mgmt)
      #       ? var.vm_configs[vm_key].vm_int_alias[index]
      #       : null
      #     )
      #     ip_address = (
      #       var.vm_configs[vm_key].vm_ips[index] != null
      #       ? format("%s/%s", var.vm_configs[vm_key].vm_ips[index], var.vm_configs[vm_key].vm_netmask[index])
      #       : null
      #     )
      #     mac_address = try(vm.network_interface[index].mac_address, "No MAC Assigned")
      #     ipv4_gateway = (
      #       index == 0 && can(var.vm_configs[vm_key].vm_mgmt_gateway)
      #       ? var.vm_configs[vm_key].vm_mgmt_gateway
      #       : null
      #     )
      #     # alias_name = (
      #     #   index > 0 # Exclude first network (mgmt)
      #     #   ? "ens${index}"
      #     #   : null
      #     # )
      #   }
      # ]
    }
  }
}


