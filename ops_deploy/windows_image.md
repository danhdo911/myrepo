## Step 1: Upload Images

### Upload Windows Installation ISO

```bash
openstack image create "[Windows ISO Name]" --insecure  --public --protected --progress \
  --disk-format iso \
  --container-format bare \
  --file /path/[en_windows_server_20xx_x64_dvd_virtio.iso] \
```

### Upload VirtIO Driver ISO

```bash
openstack image create "[VirtIO ISO Name]" --insecure --public --protected --progress \
  --disk-format iso \
  --container-format bare \
  --file /path/[virtio-win-x.x.xxx.iso]
```

## Step 2: Create Volumes

### Create the installation media volume

```bash
openstack volume create --insecure --image [Windows ISO Name] --size 10 --bootable [windows20xx-installation-volume] --type [volume_type_name]
```

### Create VirtIO driver media volume

```bash
openstack volume create --insecure --image [VirtIO ISO Name] --size 2 virtio-driver-volume --type [volume_type_name]
```

### Create Windows OS Target volume

```bash
openstack volume create --insecure --size 40 --bootable [windows20xx-os-target-volume] --type [volume_type_name]
```

## Step 3: Launch Instance using the created volumes

```bash
openstack server create --insecure --flavor [flavor_name] --network [network_name] \
  --block-device source_type=volume,uuid=$(openstack volume show [windows20xx-installation-volume] -f value -c id --insecure),destination_type=volume,device_type=cdrom,boot_index=0 \
  --block-device source_type=volume,uuid=$(openstack volume show virtio-driver-volume -f value -c id --insecure),destination_type=volume,device_type=cdrom,boot_index=-1 \
  --block-device source_type=volume,uuid=$(openstack volume show [windows20xx-os-target-volume] -f value -c id --insecure),destination_type=volume,device_type=disk,boot_index=1 \
[Instance-Name]
```

## Step 4: Configure Instance

### Install VirtIO Drivers

https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso

After Windows installation has completed, install the necessary drivers from VirtIO ISO.

### Delete Recovery Partition (Optional)

![image][pasted-2026.06.19-15.23.20.png]

### Cloud-Init and QEMU guest agent configurations (Optional)

To be able to use Cloudbase-Init, we have to configure the following policy from PowerShell:

```bash
Set-ExecutionPolicy Unrestricted
```

### Change the SAN policy to OnlineAll (Optional)

```bash
PS C:\Windows\system32> diskpart

DISKPART> san

DISKPART> san policy=onlineall
```

NOTE:

| Type  | Description |
| ------------- | ------------- |
| OnlineAll  | All newly detected disks are automatically brought online.  |
| OfflineShared  | All disks on sharable buses, such as iSCSI and FC, are left offline by default, while disks on non-sharable buses are kept online. |
| OfflineInternal | All newly detected disks are left offline. |

### Install Cloudbase-Init

https://cloudbase.it/downloads/CloudbaseInitSetup_Stable_x64.msi

- Download and Run Cloudbase-Init.
- Select the option to run Sysprep for creating a generalized golden image.
- Allow the VM to power off automatically upon completion.

## Step 5: Create Golden Image

### Shutdown instance & detach Windows Installer  volume

```bash
openstack --insecure server remove volume [Instance_name] [windows20xx-os-target-volume]
```

- Create a Glance Image from the Windows Installer volume

```bash
openstack --insecure image create "[Windows Image Name]" --disk-format qcow2 --volume [windows20xx-os-target-volume] --public --protected
```

### Set Image metadata

```bash
openstack --insecure image set [Windows Image Name] --min-disk 40 --min-ram 4096 \
  --property hw_boot_menu=true \
  --property hw_cdrom_bus=sata \
  --property hw_disk_bus=scsi \
  --property hw_firmware_type=uefi \
  --property hw_machine_type=q35 \
  --property hw_scsi_model=virtio-scsi \
  --property hw_qemu_guest_agent=yes \
  --property os_admin_user=administrator \
  --property os_distro=windows \
  --property os_type=windows \
  --property os_version=[20xx]
```

## Step 6: Change Image Owner (Optional)

```bash
openstack image set --project [Destination Project Name] [Image Name]
```
