### Hashi Vault ###
vault_secret_path = "iijvn-ansiblevsphere"
vault_secret_data = "iijvnrsvcsa01"

varoot_password = "vcd_admin_pwd"
admin_pwd       = "vcd_admin_pwd"
db_pwd          = "vcd_db_pwd"

### vSphere Information ###
vsphere_server         = "iijvnrsvcsa01.iijvn.lab"
vsphere_unverified_ssl = "true"
vsphere_datacenter     = "Datacenter"
vsphere_cluster        = "RS-Cluster"
vsphere_resource_pool  = "/Resources/IIJVN.LOCAL/MGMT/vCD"
vsphere_host           = "host15.lab.local"
vsphere_datastore      = "vsanDS"
vsphere_network_01     = "DS_vSAN_138"
vsphere_network_02     = "DPG_vCD_DB"

### vCD Configurations ###
local_ovf_path       = "/nfs/vcd/VMware_Cloud_Director-10.6.1.11753-24532678_OVF10.ova"
deployment_option    = "primary-medium"
vcd_vm_name          = "iijvndevvcd02"
ntp_server           = "192.168.137.200"
expire_root_password = "False"
enable_ssh           = "True"
routes0              = ""
routes1              = ""
gateway              = "192.168.138.1"
domain               = "iijvn.local"
searchpath           = "iijvn.local"
dns_server           = "192.168.138.11,192.168.138.12"
ip0                  = "192.168.138.150"
netmask0             = "255.255.255.0"
ip1                  = "100.100.30.214"
netmask1             = "255.255.255.0"
ceip_enabled         = "False"
nfs_mount            = "192.168.138.40:/nfsshare"
admin_email          = "danh.do@ap.iij.com.vn"
admin_fname          = "vCD Admin"
admin_uname          = "administrator"
installation_id      = "1"
sys_name             = "iijvndevvcd02"

### Health Check ###
wait_for_ssh_script = "wait_for_ssh.sh"

vcd_api_version     = "39.0"
health_check_script = "vcd_health_check.sh"

vcd_tail_cell_log_script = "vcd_tail_cell_log.sh"