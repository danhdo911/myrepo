packer {
  required_plugins {
    vsphere = {
      version = "1.4.2"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}

locals {
  vsphere_user   = "${vault("${var.vault_data}", "${var.vsphere_user}")}"
  vsphere_password = "${vault("${var.vault_data}", "${var.vsphere_password}")}"
}

source "vsphere-iso" "linux-ubuntu-server" {
  vcenter_server        = var.vsphere_server
  username              = local.vsphere_user
  password              = local.vsphere_password
  insecure_connection   = var.vspher_unverified_ssl
  datacenter            = var.vsphere_datacenter
  cluster               = var.vsphere_cluster
  datastore             = var.vsphere_datastore
  folder                = var.vcenter_folder
  resource_pool         = var.resource_pool

  vm_name               = var.vm_name
  vm_version            = var.vm_version
  guest_os_type         = var.vm_guest_os_type
  CPUs                  = var.vm_num_cpus
  cpu_cores             = var.vm_cores_per_socket
  CPU_hot_plug          = var.vm_cpu_hot_plug
  RAM                   = var.vm_memory
  RAM_hot_plug          = var.vm_memory_hot_plug
  disk_controller_type  = [var.vm_disk_controller_type]
  
  storage {
    disk_size             = var.vm_disk_size
    disk_thin_provisioned = var.vm_disk_thin_provision
  }
  network_adapters {
    network       = var.vm_portgroup_name
    network_card  = var.vm_network_card_type
  }

  ssh_username  = var.vm_user_login
  ssh_password  = var.vm_user_password
  ssh_port      = var.vm_ssh_port
  ssh_timeout   = var.vm_ssh_wait_timeout

  iso_paths = [var.iso_path]
  cd_files = [var.cloud_init_files]
  cd_label  = var.cd_label
  
  boot_command = ["<wait>e<down><down><down><end> autoinstall ds=nocloud;<F10>"]

  convert_to_template = var.convert_to_template
}

build {
  sources = [
    "source.vsphere-iso.linux-ubuntu-server"
  ]
  provisioner "shell" {
    script          = var.script_setup
    execute_command = "{{.Vars}} bash '{{.Path}}'"
  }

  provisioner "shell-local" {
    inline = [
      "echo The image is created successfully"
    ]
  }
 }