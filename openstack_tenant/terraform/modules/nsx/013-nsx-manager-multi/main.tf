## Deployment of VM from Local OVF
resource "vsphere_virtual_machine" "nsx_managers" {
  for_each = { for nsx in var.nsx_managers : nsx.nsx_vm_name => nsx }

  name                 = each.value.nsx_vm_name
  datacenter_id        = data.vsphere_datacenter.datacenter.id
  datastore_id         = data.vsphere_datastore.datastore.id
  host_system_id       = data.vsphere_host.host[each.key].id
  resource_pool_id     = data.vsphere_resource_pool.default.id
  num_cpus             = data.vsphere_ovf_vm_template.ovfLocal[each.key].num_cpus
  num_cores_per_socket = data.vsphere_ovf_vm_template.ovfLocal[each.key].num_cores_per_socket
  memory               = data.vsphere_ovf_vm_template.ovfLocal[each.key].memory
  guest_id             = data.vsphere_ovf_vm_template.ovfLocal[each.key].guest_id
  scsi_type            = data.vsphere_ovf_vm_template.ovfLocal[each.key].scsi_type
  nested_hv_enabled    = data.vsphere_ovf_vm_template.ovfLocal[each.key].nested_hv_enabled

  dynamic "network_interface" {
    for_each = data.vsphere_ovf_vm_template.ovfLocal[each.key].ovf_network_map
    content {
      network_id = network_interface.value
    }
  }
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0

  ovf_deploy {
    allow_unverified_ssl_cert = true ## true if we use self-signed certificates / false if we use trusted certificates
    local_ovf_path            = data.vsphere_ovf_vm_template.ovfLocal[each.key].local_ovf_path
    disk_provisioning         = data.vsphere_ovf_vm_template.ovfLocal[each.key].disk_provisioning
    ovf_network_map           = data.vsphere_ovf_vm_template.ovfLocal[each.key].ovf_network_map
    deployment_option         = var.deployment_option
  }

  vapp {
    properties = {
      "nsx_role"               = var.nsx_role,
      "nsx_grub_passwd"        = local.nsx_grub_passwd
      "nsx_grub_menu_timeout"  = var.nsx_grub_menu_timeout
      "nsx_passwd_0"           = local.nsx_passwd_0
      "nsx_cli_passwd_0"       = local.nsx_cli_passwd_0
      "nsx_cli_audit_passwd_0" = local.nsx_cli_audit_passwd_0
      "nsx_cli_username"       = var.nsx_cli_username
      "nsx_cli_audit_username" = var.nsx_cli_audit_username
      "nsx_hostname"           = each.value.nsx_hostname
      "nsx_ip_0"               = each.value.ip_address
      "nsx_netmask_0"          = var.nsx_netmask_0
      "nsx_gateway_0"          = var.nsx_gateway_0
      "nsx_dns1_0"             = var.nsx_dns1_0
      "nsx_domain_0"           = var.nsx_domain_0
      "nsx_ntp_0"              = var.nsx_ntp_0
      "nsx_isSSHEnabled"       = var.nsx_isSSHEnabled
      "nsx_allowSSHRootLogin"  = var.nsx_allowSSHRootLogin
    }
  }

  lifecycle {
    ignore_changes = [
      annotation,
      disk[0].io_share_count,
      vapp[0].properties,
    ]
  }
}
