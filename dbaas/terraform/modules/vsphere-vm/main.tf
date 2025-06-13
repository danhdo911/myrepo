data "vsphere_datacenter" "datacenter" {
  name = var.vsphere_datacenter
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.vsphere_resource_pool
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_folder" "folder" {
  path = "/${data.vsphere_datacenter.datacenter.name}/vm/${var.vsphere_folder}"
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = var.vm_portgroup_name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vm_template
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_virtual_machine" "vm" {

  wait_for_guest_ip_timeout  = 10
  wait_for_guest_net_timeout = 10

  count                = var.vm_numbers
  name                 = "${var.vm_name}-${format("%02d", count.index + 1)}"
  resource_pool_id     = data.vsphere_resource_pool.pool.id
  folder               = trimprefix(data.vsphere_folder.folder.path, "/${data.vsphere_datacenter.datacenter.name}/vm")
  datastore_id         = data.vsphere_datastore.datastore.id
  num_cpus             = var.vm_num_cpus
  num_cores_per_socket = var.vm_cores_per_socket
  memory               = var.vm_memory
  guest_id             = data.vsphere_virtual_machine.template.guest_id

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label = var.vm_disk_label
    size  = var.vm_disk_size == "" ? data.vsphere_virtual_machine.template.disks.0.size : var.vm_disk_size
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = "${var.vm_name}-${format("%02d", count.index + 1)}"
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
      "sudo echo ${var.vm_user_ssh_public_key} >> ~/.ssh/authorized_keys",
    ]
  }

}
