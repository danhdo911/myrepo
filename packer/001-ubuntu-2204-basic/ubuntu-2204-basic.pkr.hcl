packer {
  required_plugins {
    vsphere = {
      version = "1.4.2"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}

source "vsphere-iso" "this" {
  vcenter_server      = var.vsphere_server
  username            = var.vsphere_user
  password            = var.vsphere_password
  datacenter          = var.datacenter
  cluster             = var.cluster
  insecure_connection = true

  vm_name       = "ubuntu"
  guest_os_type = "ubuntu64Guest"
  convert_to_template = true

  CPUs            = 2
  RAM             = 2048
  RAM_reserve_all = true

  ssh_username = "ubuntu"
  ssh_password = var.vm_ssh_password
  ssh_timeout  = "30m"

  disk_controller_type = ["pvscsi"]
  datastore            = var.datastore
  storage {
    disk_size             = 16384
    disk_thin_provisioned = true
  }

  iso_paths = ["[TESTMIGRATE] ISO/ubuntu-22.04.5-live-server-amd64.iso"]

  network_adapters {
    network = var.network_name
    network_card  = "vmxnet3"
  }

  cd_files = ["./cloud-init/meta-data", "./cloud-init/user-data"]
  cd_label = "cidata"
  
  boot_command = ["<wait>e<down><down><down><end> autoinstall ds=nocloud;<F10>"]

}

build {
  sources = [
    "source.vsphere-iso.this"
  ]

  provisioner "shell" {
    script       = "./scripts/setup-script.sh"
    execute_command = "{{.Vars}} bash '{{.Path}}'"
  }

  provisioner "shell-local" {
    inline = [
      "echo Ubuntu Image is created successfully"
    ]
  }
}
