data "vsphere_datacenter" "datacenter" {
  name = var.vsphere_datacenter
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_datastore" "datastore" {
  for_each      = var.vm_configs
  name          = each.value.vm_datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  for_each      = var.vm_configs
  name          = each.value.vm_portgroup_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vm_template
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_virtual_machine" "vm" {

  wait_for_guest_ip_timeout  = 10
  wait_for_guest_net_timeout = 10

  for_each = var.vm_configs

  name                 = each.value.vm_name
  resource_pool_id     = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id         = data.vsphere_datastore.datastore[each.key].id
  num_cpus             = each.value.vm_num_cpus
  num_cores_per_socket = each.value.vm_cores_per_socket
  memory               = each.value.vm_memory
  guest_id             = data.vsphere_virtual_machine.template.guest_id

  network_interface {
    network_id   = data.vsphere_network.network[each.key].id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label = each.value.vm_disk_label
    size  = each.value.vm_disk_size == "" ? data.vsphere_virtual_machine.template.disks.0.size : each.value.vm_disk_size
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = each.value.vm_name
        domain    = ""
      }
      network_interface {}
    }
  }

  provisioner "remote-exec" {
    connection {
      type     = var.vm_remote_type
      user     = var.vm_user_login
      password = var.vm_user_password
      host     = self.default_ip_address
    }
    inline = [
      "sudo echo ${each.value.vm_ssh_public_key} >> ~/.ssh/authorized_keys",
    ]
  }

}
