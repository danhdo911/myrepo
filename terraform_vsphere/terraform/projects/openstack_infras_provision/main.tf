module "ops_vm" {
  source = "../../modules/vm/005-provision-ops-vm"

  vsphere_datacenter    = var.vsphere_datacenter
  vsphere_cluster       = var.vsphere_cluster
  vsphere_resource_pool = var.vsphere_resource_pool

  vm_template       = var.vm_template
  vm_ssh_public_key = var.vm_ssh_public_key
  dns_server_list   = var.dns_server_list

  vm_configs = var.vm_configs
}

resource "null_resource" "export_vms_info" {
  depends_on = [module.ops_vm]

  triggers = {
    vms_info_checksum = sha1(jsonencode(module.ops_vm.vms_info))
  }

  provisioner "local-exec" {
    command = <<-EOT
      terraform output -json vms_info > /iijvn/openstack/data_build/vms_info.json
    EOT
  }
}

resource "null_resource" "netplan" {
  depends_on = [
    module.ops_vm,
    resource.null_resource.export_vms_info
  ]

  provisioner "local-exec" {
    command = <<-EOT
      cd /iijvn/openstack/
      ansible all -i inventories/lab -m ping
      ansible-playbook playbooks/pre-setup-ops.yml -i inventories/lab -t "netplan"
    EOT
  }
}