resource "vsphere_virtual_machine" "vcenter_appliance" {
  name                 = var.vcenter_vm_name
  num_cpus             = data.vsphere_ovf_vm_template.ovfLocal.num_cpus
  num_cores_per_socket = data.vsphere_ovf_vm_template.ovfLocal.num_cores_per_socket
  memory               = data.vsphere_ovf_vm_template.ovfLocal.memory
  guest_id             = data.vsphere_ovf_vm_template.ovfLocal.guest_id
  scsi_type            = data.vsphere_ovf_vm_template.ovfLocal.scsi_type

  datacenter_id    = data.vsphere_datacenter.datacenter.id
  resource_pool_id = data.vsphere_resource_pool.default.id
  host_system_id   = data.vsphere_host.host.id
  datastore_id     = data.vsphere_datastore.datastore.id

  cpu_hot_add_enabled    = var.cpu_hot_add_enabled
  cpu_hot_remove_enabled = var.cpu_hot_remove_enabled
  memory_hot_add_enabled = var.memory_hot_add_enabled

  dynamic "network_interface" {
    for_each = data.vsphere_ovf_vm_template.ovfLocal.ovf_network_map
    content {
      network_id = network_interface.value
    }
  }

  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0

  ovf_deploy {
    allow_unverified_ssl_cert = var.allow_unverified_ssl_cert
    local_ovf_path            = data.vsphere_ovf_vm_template.ovfLocal.local_ovf_path
    disk_provisioning         = data.vsphere_ovf_vm_template.ovfLocal.disk_provisioning
    ovf_network_map           = data.vsphere_ovf_vm_template.ovfLocal.ovf_network_map
    deployment_option         = data.vsphere_ovf_vm_template.ovfLocal.deployment_option
  }

  vapp {
    properties = {
      "guestinfo.cis.deployment.autoconfig"     = var.deployment_autoconfig
      "guestinfo.cis.appliance.net.addr.family" = var.vcenter_net_addr_family
      "guestinfo.cis.appliance.net.mode"        = var.vcenter_net_mode
      "guestinfo.cis.appliance.net.addr"        = var.vcenter_ipv4_address
      "guestinfo.cis.appliance.net.dns.servers" = var.vcenter_net_dns_server
      "guestinfo.cis.appliance.net.prefix"      = var.vcenter_net_prefix
      "guestinfo.cis.appliance.net.gateway"     = var.vcenter_net_gateway
      "guestinfo.cis.appliance.net.pnid"        = var.vcenter_fqdn_name
      "guestinfo.cis.appliance.root.passwd"     = var.vcenter_password
      "guestinfo.cis.vmdir.password"            = var.vcenter_password
      "domain"                                  = var.vcenter_domain
      "guestinfo.cis.ceip_enabled"              = var.ceip_enabled
    }
  }

  provisioner "local-exec" {
    // without a provisioner, the deployment would return once VMware tools sees an IP address
    // this waits for the appliance system health api to return green
    command = var.health_check_script
    environment = {
      VCENTER_HOSTNAME = var.vcenter_fqdn_name
      VCENTER_USERNAME = var.vcenter_username
      VCENTER_PASSWORD = var.vcenter_password
      TIMEOUT          = var.health_check_timeout
    }
  }

  # provisioner "remote-exec" {
  #   connection {
  #     type     = var.vcenter_remote_type
  #     host     = var.vcenter_ipv4_address
  #     user     = var.vcenter_appliance_username
  #     password = var.vcenter_password
  #     timeout  = var.vcenter_remote_timeout
  #   }
  #   inline = [
  #     "ntp.set --servers ${var.ntp_server_01},${var.ntp_server_02}",
  #     "timesync.set --mode NTP",
  #   ]
  # }

  lifecycle {
    ignore_changes = [
      vapp,
    ]
  }
}