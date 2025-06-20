resource "vsphere_virtual_machine" "vm" {

  wait_for_guest_ip_timeout  = 10
  wait_for_guest_net_timeout = 10

  for_each = var.vm_configs

  name                   = each.value.vm_name
  resource_pool_id       = data.vsphere_resource_pool.pool.id
  host_system_id         = data.vsphere_host.host.id
  folder                 = trimprefix(data.vsphere_folder.folder.path, "/${data.vsphere_datacenter.datacenter.name}/vm")
  datastore_id           = data.vsphere_datastore.datastore[each.key].id
  num_cpus               = each.value.vm_num_cpus
  num_cores_per_socket   = each.value.vm_cores_per_socket
  cpu_hot_add_enabled    = true
  memory                 = each.value.vm_memory
  memory_hot_add_enabled = true
  guest_id               = data.vsphere_virtual_machine.template.guest_id

  dynamic "network_interface" {
    for_each = each.value.vm_networks
    content {
      network_id   = data.vsphere_network.network[network_interface.value].id
      adapter_type = "vmxnet3"
    }
  }

  disk {
    label       = each.value.vm_disk_label[0]
    size        = each.value.vm_disk_size[0] == "" ? data.vsphere_virtual_machine.template.disks.0.size : each.value.vm_disk_size[0]
    unit_number = 0
  }

  dynamic "disk" {
    for_each = slice(each.value.vm_disk_label, 1, length(each.value.vm_disk_label))
    content {
      label = disk.value != null ? disk.value : null
      size = disk.value != null ? each.value.vm_disk_size[index(each.value.vm_disk_label, disk.value)] : null
      unit_number = disk.value != null ? index(each.value.vm_disk_label, disk.value) : null
    }
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = each.value.vm_name
        domain    = ""
      }

      dynamic "network_interface" {
        for_each = toset(range(length(each.value.vm_ips)))
        content {
          ipv4_address = each.value.vm_ips[network_interface.key]
          ipv4_netmask = each.value.vm_netmask[network_interface.key]
        }
      }

      ipv4_gateway    = each.value.vm_mgmt_gateway
      dns_server_list = var.dns_server_list
    }
  }

  provisioner "remote-exec" {
    connection {
      type     = var.vm_remote_type
      user     = var.vm_user_login
      password = var.vm_user_password
      host     = each.value.vm_ips[0]
      timeout  = "10m"
    }

    inline = [
      "#!/bin/bash",
      "set -euxo pipefail",

      # Ensure SSH setup
      "if [ ! -d /home/${var.vm_user_login}/.ssh ]; then sudo mkdir -p /home/${var.vm_user_login}/.ssh; fi",
      "sudo chmod 700 /home/${var.vm_user_login}/.ssh",
      "echo '${var.vm_ssh_public_key}' | sudo tee -a /home/${var.vm_user_login}/.ssh/authorized_keys",
      "sudo chmod 600 /home/${var.vm_user_login}/.ssh/authorized_keys",
      "sudo chown -R ${var.vm_user_login}:${var.vm_user_login} /home/${var.vm_user_login}/.ssh",
    ]
  }
}