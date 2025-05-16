### vSphere Information ###
vsphere_server         = "192.168.138.247"
vsphere_unverified_ssl = "true"
vsphere_datacenter     = "Auto-DC"
vsphere_cluster        = "ClusterA01"
vsphere_host           = "192.168.138.248"
vsphere_datastore      = "TESTMIGRATE"

### NSX Manager Configuration ###

# General configuration for NSX Managers
general_password = "P@ssw0rd2024"
# nsx_passwd_0           = "P@ssw0rd2024"
# nsx_cli_passwd_0       = "P@ssw0rd2024"
# nsx_cli_audit_passwd_0 = "P@ssw0rd2024"
# nsx_grub_passwd        = "P@ssw0rd2024"
local_ovf_path         = "/nfs/nsx/nsx-unified-appliance-4.1.2.3.0.23382420.ova"
disk_provisioning      = "thin"
deployment_option      = "extra_small"
nsx_role               = "NSX Manager"
nsx_cli_username       = "admin"
nsx_cli_audit_username = "audit"
nsx_grub_menu_timeout  = "5"
nsx_netmask_0          = "255.255.255.0"
nsx_gateway_0          = "192.168.138.1"
nsx_dns1_0             = "192.168.138.240"
nsx_domain_0           = "dd-iaas.local"
nsx_ntp_0              = "192.168.138.241"
nsx_isSSHEnabled       = "True"
nsx_allowSSHRootLogin  = "True"

# Specific configuration for each NSX Manager
nsx_managers = [
  {
    nsx_vm_name     = "nsx-provision-01"
    vsphere_host    = "192.168.138.248"
    vsphere_network = "vDS-PG-VLAN138"
    nsx_hostname    = "nsx-provision-01"
    ip_address      = "192.168.138.236"
    # datastore        = "datastore-01"
    # network          = "network-01"
    # resource_pool    = "Resources"
    # netmask          = "255.255.255.0"
    # gateway          = "192.168.1.1"
    # dns              = "192.168.1.2"
    # ntp              = "192.168.1.3"
    # domain           = "example.com"
    # is_ssh_enabled   = true
    # allow_ssh_root   = true
    # cli_username     = "admin"
    # cli_password     = "password123"
    # cli_audit_user   = "audit"
    # cli_audit_passwd = "audit123"
  },
  # {
  #   nsx_vm_name     = "nsx-provision-02"
  #   vsphere_host    = "192.168.138.248"
  #   vsphere_network = "vDS-PG-VLAN138"
  #   nsx_hostname    = "nsx-provision-02"
  #   ip_address      = "192.168.138.237"
  #   # datastore        = "datastore-02"
  #   # network          = "network-02"
  #   # resource_pool    = "Resources"
  #   # netmask          = "255.255.255.0"
  #   # gateway          = "192.168.2.1"
  #   # dns              = "192.168.2.2"
  #   # ntp              = "192.168.2.3"
  #   # domain           = "example.com"
  #   # is_ssh_enabled   = true
  #   # allow_ssh_root   = true
  #   # cli_username     = "admin"
  #   # cli_password     = "password123"
  #   # cli_audit_user   = "audit"
  #   # cli_audit_passwd = "audit123"
  # }
]
