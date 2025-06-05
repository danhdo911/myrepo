module "ops_vm" {
  source = "../../terraform/modules/vm/005-provision-ops-vm"

  vsphere_datacenter    = var.vsphere_datacenter
  vsphere_cluster       = var.vsphere_cluster
  vsphere_resource_pool = var.vsphere_resource_pool
  vsphere_folder        = var.vsphere_folder

  vm_template       = var.vm_template
  vm_ssh_public_key = var.vm_ssh_public_key
  dns_server_list   = var.dns_server_list

  vm_configs = var.vm_configs
}

# resource "null_resource" "export_vms_info" {
#   depends_on = [module.ops_vm]

#   triggers = {
#     vms_info_checksum = sha1(jsonencode(module.ops_vm.vms_info))
#   }

#   provisioner "local-exec" {
#     interpreter = ["bash", "-c"]
#     command = <<-EOT
#       terraform output -json vms_info > /iijvn/openstack/data_build/vms_info.json
#     EOT
#     on_failure  = "continue"

#   }
# }

# resource "local_file" "vms_info" {
#   depends_on = [module.ops_vm]


#   content  = jsonencode(module.ops_vm.vms_info)
#   filename = "${path.module}/vms_info.json"
# }

# resource "null_resource" "ansible_tasks" {
#   depends_on = [
#     module.ops_vm,
#     resource.local_file.vms_info
#   ]

#   triggers = {
#     vms_info_checksum = sha1(jsonencode(module.ops_vm.vms_info))
#   }

#   provisioner "local-exec" {
#     command    = <<-EOT
#       cp ${path.module}/vms_info.json /iijvn/openstack/data_build/vms_info.json
#       cd /iijvn/openstack/
#       python3 ./scripts/inventory.py --input_file data_build/vms_info.json --output-file inventories/dynamic_ops.ini
#       ansible all -i inventories/lab -m ping
#     EOT
#     on_failure = continue
#   }
# }