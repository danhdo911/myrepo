data "vsphere_datacenter" "datacenter" {
  name = var.vsphere_datacenter
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
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

  name             = var.vm_name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = var.vm_num_cpus
  memory           = var.vm_memory
  guest_id         = data.vsphere_virtual_machine.template.guest_id

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label = var.vm_disk_label
    size  = data.vsphere_virtual_machine.template.disks.0.size
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = var.vm_name
        domain    = ""
      }
      network_interface {}
    }
  }
  # provisioner "remote-exec" {
  #   connection {
  #     type     = var.vm_remote_type
  #     user     = var.vm_user_login
  #     password = var.vm_user_password
  #     host     = vsphere_virtual_machine.vm.default_ip_address
  #   }
  #   inline = [ 
  #     "echo ${var.vm_user_password} | sudo -S su",
  #     "sudo hostnamectl set-hostname ${var.vm_name}"
  #    ]
  # }
}


