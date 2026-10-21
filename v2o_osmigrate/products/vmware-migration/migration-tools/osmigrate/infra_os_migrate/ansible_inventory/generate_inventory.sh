#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKDIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

ENV_FILE="${ENV_FILE:-}"

if [[ ! -f "$ENV_FILE" ]]; then
    echo "[FAIL] Environment file not found: $ENV_FILE"
    exit 1
fi

echo "[INFO] Loading environment file: $ENV_FILE"

set -a
source "$ENV_FILE"
set +a

log() {
    echo "[INFO] $*"
}

fail() {
    echo "[ERROR] $*" >&2
    exit 1
}

update_inventory() {
    local inventory_file="environments/${ENV}/inventory"

    log "Updating inventory: ${inventory_file}"

    mkdir -p "$(dirname "$inventory_file")"

    cat > "$inventory_file" <<EOF
[all]

[migrator]
localhost

[migrator:vars]
ansible_connection=local
ansible_python_interpreter=/usr/bin/python3.12

[conversion_host]
${CONVERSION_FLOATING_IP}

[conversion_host:vars]
ansible_user=cloud-user
ansible_ssh_private_key_file=/root/.ssh/vmware-conv-host
EOF

    log "Inventory updated."
}

main() {
    update_inventory
}

main "$@"