#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load inventory
source "${SCRIPT_DIR}/.inventory"

# Ceph bootstrap node
BOOTSTRAP_HOST="${CONTROLLER_01}"

# SSH configuration
ADMIN_SSH_KEY="/root/.ssh/id_ed25519"
CEPH_PUB_KEY="${SCRIPT_DIR}/ceph.pub"

SSH_OPTIONS=(
    -o StrictHostKeyChecking=no
    -o IdentityFile="$ADMIN_SSH_KEY"
    -o IdentitiesOnly=yes
    -o BatchMode=yes
)

# All Ceph hosts
HOSTS=(
    "$CONTROLLER_01"
    "$CONTROLLER_02"
    "$CONTROLLER_03"
    "$COMPUTE_01"
    "$COMPUTE_02"
    "$COMPUTE_03"
)

# Export Cephadm SSH public key
echo "[INFO] Exporting Cephadm SSH public key..."
ceph cephadm get-pub-key > "$CEPH_PUB_KEY"

# Get existing Ceph hosts
EXISTING_HOSTS="$(ceph orch host ls --format json | jq -r '.[].hostname')"

for host in "${HOSTS[@]}"; do
    if [[ "$host" == "$BOOTSTRAP_HOST" ]]; then
        echo "[INFO] Skipping bootstrap host: $host"
        continue
    fi

    echo "[INFO] Processing host: $host"

    # Retrieve remote hostname
    HOSTNAME="$(ssh "${SSH_OPTIONS[@]}" "root@${host}" hostname)"

    if [[ -z "$HOSTNAME" ]]; then
        echo "[ERROR] Failed to retrieve hostname from $host"
        exit 1
    fi

    echo "[INFO] Remote hostname: $HOSTNAME"

    # Install Cephadm SSH public key
    echo "[INFO] Configuring Cephadm SSH access: $host"

    ssh-copy-id -f \
        "${SSH_OPTIONS[@]}" \
        -i "$CEPH_PUB_KEY" \
        "root@${host}"

    # Skip hosts already registered
    if grep -Fxq "$HOSTNAME" <<< "$EXISTING_HOSTS"; then
        echo "[INFO] Host already registered: $HOSTNAME"
        continue
    fi

    # Add host to Ceph cluster
    echo "[INFO] Adding Ceph host: $HOSTNAME ($host)"

    ceph orch host add "$HOSTNAME" "$host"

    echo "[INFO] Successfully added: $HOSTNAME"
done

# Verify hosts
echo "[INFO] Ceph host inventory:"
ceph orch host ls

echo "[INFO] Ceph host registration completed."
