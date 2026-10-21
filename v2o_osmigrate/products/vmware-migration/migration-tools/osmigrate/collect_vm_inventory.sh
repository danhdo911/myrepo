#!/bin/bash
set -euo pipefail

ENV_FILE="${ENV_FILE:-}"

if [[ ! -f "$ENV_FILE" ]]; then
    echo "[FAIL] Environment file not found: $ENV_FILE"
    exit 1
fi

echo "[INFO] Loading environment file: $ENV_FILE"

set -a
source "$ENV_FILE"
set +a

vm_name=${vm_name:-}

search_path=${search_path:-$VMWARE_SEARCH_PATH}

output_path=${output_path:-output}
output_origin="$output_path/vm_data_export.json"
output_filterred="$output_path/vm_data_filtered.json"

if [ ! -d "$output_path" ]; then
    echo "The $output_path directory does not exist. Creating it now..."
    mkdir -p "$output_path"
fi

### Gather VM inventory
inventory_plugin=${inventory_plugin:-inventory.vmware_vms.yml}
inventory_tmp="tmp.vmware_vms.yml"

trap "rm -f $inventory_tmp" EXIT
envsubst < $inventory_plugin > $inventory_tmp

cmd=(
    docker compose -f docker-compose.yml run --rm --user 0:0 ansible 
    "ansible-inventory -i $inventory_tmp --list"
)

if [[ -n "${vm_name:-}" ]]; then
    cmd+=(--limit "$vm_name")
fi

"${cmd[@]}" > "$output_origin"

### Data filtered
jq '
def unwrap_ansible_unsafe:
  if type == "object" and has("__ansible_unsafe") then
    .__ansible_unsafe
  elif type == "object" then
    with_entries(.value |= unwrap_ansible_unsafe)
  elif type == "array" then
    map(unwrap_ansible_unsafe)
  else
    .
  end;

unwrap_ansible_unsafe
| ._meta.hostvars
| with_entries(
    .value = {
      name: (.value.name // .key),
      moid: .value.moid,
      path: .value.path,
      power_state: .value.summary.runtime.powerState,
      template: .value.config.template,
      guest_os_fullname: .value.config.guestFullName,
      guest_id: .value.config.guestId,
      os_name: (
        (
          (.value.guest.guestDetailedData // "")
          | try capture("distroName='\''(?<v>[^'\'']+)'\''").v
        ) // "Unknown"
      ),
      os_version: (
        (
          (.value.guest.guestDetailedData // "")
          | try capture("distroVersion='\''(?<v>[^'\'']+)'\''").v
        ) // "Unknown"
      ),
      firmware: .value.config.firmware,
      vmtools_version: .value.config.tools.toolsVersion,
      hardware_version: .value.guest.hwVersion,
      ip: (.value.guest.ipAddress // .value.ansible_host),

      resources: {
        cpu: .value.config.hardware.numCPU,
        cores_per_socket: .value.config.hardware.numCoresPerSocket,
        memory_mb: .value.config.hardware.memoryMB
      },

      disks: [
        .value.config.hardware.device[]?
        | select(._vimtype == "vim.vm.device.VirtualDisk")
        | {
            datastore: (
              .backing.fileName
              | capture("^\\[(?<name>[^]]+)\\]")?
              | .name
            ),
            label: .deviceInfo.label,
            key: .key,
            size_gb: (.capacityInBytes / 1073741824),
            thin: .backing.thinProvisioned,
            filename: .backing.fileName
          }
      ],

      networks: [
        .value as $vm
        | $vm.guest.net[]? as $guest_nic
        | (
            $vm.config.hardware.device[]?
            | select(
                .macAddress? != null
                and (.macAddress | ascii_downcase)
                    == ($guest_nic.macAddress | ascii_downcase)
              )
          ) as $device
        | {
            mac: $guest_nic.macAddress,
            connected: $guest_nic.connected,
            addresses: $guest_nic.ipAddress,
            network: $guest_nic.network,
            network_id: $device.backing.port.portgroupKey,
            adapter: $device.deviceInfo.label
          }
      ],

      dns_servers: [
        .value.guest.ipStack[]?
        | {
            dhcp: .dnsConfig.dhcp,
            servers: .dnsConfig.ipAddress,
            search_domains: .dnsConfig.searchDomain
          }
      ],

      routes: [
        .value.guest.ipStack[]?.ipRouteConfig.ipRoute[]?
        | {
            network,
            prefix: .prefixLength,
            gateway: .gateway.ipAddress
          }
      ]
    }
  )
' "$output_origin" > "$output_filterred"

### Validation
if [[ ! -s "$output_filterred" ]]; then
    echo "ERROR: VM inventory was not generated or is empty"
    exit 1
fi

echo "VM inventory collection completed successfully."