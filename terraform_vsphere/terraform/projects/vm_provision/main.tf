module "ops_vm" {
  source = "../../modules/vm/005-provision-ops-vm"

  vsphere_datacenter    = var.vsphere_datacenter
  vsphere_cluster       = var.vsphere_cluster
  vsphere_resource_pool = var.vsphere_resource_pool
  vsphere_folder        = var.vsphere_folder

  vm_template       = var.vm_template
  vm_ssh_public_key = var.vm_ssh_public_key
  dns_server_list   = var.dns_server_list

  vm_configs = var.vm_configs
}

resource "null_resource" "export_vms_info" {
  depends_on = [module.ops_vm]

  triggers = {
    vms_info_checksum = sha1(jsonencode(module.ops_vm.vms_info))
    # always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<-EOT
      terraform output -json vm_provision > /iijvn/openstack/data_build/vm_provision.json
    EOT
  }
}

resource "null_resource" "netplan" {
  depends_on = [module.ops_vm, resource.null_resource.export_vms_info]

  triggers = {
    vms_info_checksum = sha1(jsonencode(module.ops_vm.vms_info))
    # always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<-EOT
      cd /iijvn/openstack/
      python3 ./scripts/inventory.py --input_file data_build/vm_provision.json --output_file inventories/dynamic_inv.ini
      ansible all -i inventories/dynamic_inv.ini -m ping
      ansible-playbook playbooks/pre-setup-ops.yml -i inventories/dynamic_inv.ini -t "os-init,ntp"
    EOT
  }
}