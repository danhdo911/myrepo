## Deployment of VM from Local OVF
resource "vsphere_virtual_machine" "vmFromLocalOvf" {
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0

  name                 = var.vcd_vm_name
  datacenter_id        = data.vsphere_datacenter.datacenter.id
  datastore_id         = data.vsphere_datastore.datastore.id
  host_system_id       = data.vsphere_host.host.id
  resource_pool_id     = data.vsphere_resource_pool.default.id
  num_cpus             = data.vsphere_ovf_vm_template.ovfLocal.num_cpus
  num_cores_per_socket = data.vsphere_ovf_vm_template.ovfLocal.num_cores_per_socket
  memory               = data.vsphere_ovf_vm_template.ovfLocal.memory
  dynamic "network_interface" {
    for_each = data.vsphere_ovf_vm_template.ovfLocal.ovf_network_map
    content {
      network_id = network_interface.value
    }
  }

  ovf_deploy {
    allow_unverified_ssl_cert = true
    local_ovf_path            = data.vsphere_ovf_vm_template.ovfLocal.local_ovf_path
    disk_provisioning         = data.vsphere_ovf_vm_template.ovfLocal.disk_provisioning
    ovf_network_map           = data.vsphere_ovf_vm_template.ovfLocal.ovf_network_map
    deployment_option         = var.deployment_option
  }

  vapp {
    properties = {
      "ntp-server"           = var.ntp_server
      "varoot-password"      = data.vault_kv_secret_v2.vault_vsphere.data["${var.varoot_password}"]
      "expire_root_password" = var.expire_root_password
      "enable_ssh"           = var.enable_ssh
      "routes0"              = var.routes0
      "routes1"              = var.routes1
      "gateway"              = var.gateway
      "domain"               = var.domain
      "searchpath"           = var.searchpath
      "DNS"                  = var.dns_server
      "ip0"                  = var.ip0
      "netmask0"             = var.netmask0
      "ip1"                  = var.ip1
      "netmask1"             = var.netmask1
      "ceip_enabled"         = var.ceip_enabled
      "nfs_mount"            = "${var.nfs_mount}/${var.sys_name}"
      "admin_email"          = var.admin_email
      "admin_fname"          = var.admin_fname
      "admin_pwd"            = data.vault_kv_secret_v2.vault_vsphere.data["${var.admin_pwd}"]
      "admin_uname"          = var.admin_uname
      "db_pwd"               = data.vault_kv_secret_v2.vault_vsphere.data["${var.db_pwd}"]
      "inst_id"              = var.installation_id
      "sys_name"             = var.sys_name
    }
  }

  provisioner "local-exec" {
    command = "${var.scripts_path}${var.wait_for_ssh_script} ${var.ip0}"
  }

  lifecycle {
    ignore_changes = [
    ]
  }
}

# Health Check Task (Runs on Terraform Machine)
resource "null_resource" "health_check" {
  depends_on = [vsphere_virtual_machine.vmFromLocalOvf]

  provisioner "local-exec" {
    command = <<EOT
    echo "Starting vCD health check..." >> ./health_check.log
    ${var.scripts_path}${var.health_check_script} >> ./health_check.log 2>&1
    EOT
    environment = {
      VCD_HOSTNAME    = var.ip0
      VCD_USERNAME    = "${var.admin_uname}@${var.org_provider}"
      VCD_PASSWORD    = data.vault_kv_secret_v2.vault_vsphere.data["${var.admin_pwd}"]
      VCD_API_VERSION = var.vcd_api_version
      TIMEOUT         = var.health_check_timeout
    }
  }
}

# Log Streaming Task (Runs on vCD VM) - need to authenticate via public key or non-interactive ssh - not test yet
# resource "null_resource" "tail_logs" {
#   depends_on = [vsphere_virtual_machine.vmFromLocalOvf]

#   connection {
#       type     = var.vcd_remote_type
#       user     = var.vcd_remote_user
#       password = var.varoot_password
#       host     = var.ip0
#     }

#   provisioner "file" {
#     source      = "${var.scripts_path}${var.vcd_tail_cell_log_script}"
#     destination = "/tmp/${var.vcd_tail_cell_log_script}"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "chmod +x /tmp/${var.vcd_tail_cell_log_script}",
#       "/tmp/${var.vcd_tail_cell_log_script}"
#     ]
#   }
# }

