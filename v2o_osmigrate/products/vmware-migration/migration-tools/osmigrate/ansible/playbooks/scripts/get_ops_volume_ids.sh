#!/bin/bash
set -euo pipefail


VM_NAME="${1}"
OUTPUT_FILE="${2:-/tmp/vm_volumes_mapping.yml}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


### SERVICE CREDENTIAL
SVC_CRED="${SVC_CRED:-/etc/kolla/admin-openrc.sh}"

if [[ ! -f "$SVC_CRED" ]]; then
    echo "ERROR: OpenStack credential file not found: $SVC_CRED"
    exit 1
fi

source /root/workdir/openstack/os-venv/bin/activate
source "$SVC_CRED"

### PROJECT NAME
PROJECT_NAME="${OS_PROJECT_NAME:-}"

if [[ -z "$PROJECT_NAME" ]]; then
    echo "ERROR: OS_PROJECT_NAME is not defined"
    exit 1
fi

PROJECT_ID=$(openstack project show "$PROJECT_NAME" -f value -c id)

### SECURITY DEFAULT GROUP
SECGRP_NAME="default"
SECGRP_ID=$(openstack security group list --project $PROJECT_ID -f value -c id -c name \
            | awk -v name=$SECGRP_NAME '$2 == name {print$1}'
            )

### VOLUME IDs
VOLUMES="$(openstack volume list --status available -f value -c id -c name)"

BOOT_VOL_ID="$(
    awk -v vm="$VM_NAME" '
        $2 == vm "-2000" {
            print $1
            exit
        }
    ' <<< "$VOLUMES"
)"

DATA_VOL_ID="$(
    awk -v vm="$VM_NAME" '
        $2 ~ ("^" vm "-[0-9]+$") &&
        $2 != vm "-2000" {
            print $1, $2
        }
    ' <<< "$VOLUMES" \
    | sort -k2,2 \
    | awk '{ print $1 }'
)"

### DATA OUTPUT
{
    echo "  ${VM_NAME}:"
    echo "    security_group: ${SECGRP_ID}"
    echo "    boot_volume_id: ${BOOT_VOL_ID}"

    if [[ -n "$DATA_VOL_ID" ]]; then
        echo "    data_volumes:"

        while IFS= read -r VOL_ID; do
            [[ -n "$VOL_ID" ]] && echo "      - id: ${VOL_ID}"
        done <<< "$DATA_VOL_ID"
    else
        echo "    data_volumes: []"
    fi
} >> "$OUTPUT_FILE"

echo "Exported volume mapping for ${VM_NAME}"