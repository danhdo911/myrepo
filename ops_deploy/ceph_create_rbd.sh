#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${OUTPUT_DIR:-${SCRIPT_DIR}/output/ceph}"

if [[ -f "${SCRIPT_DIR}/.env" ]]; then
    set -a
    source "${SCRIPT_DIR}/.env"
    set +a
fi

CEPH_POOLS=(images volumes vms backups)

REPLICA_SIZE=3
MIN_SIZE=2
CRUSH_RULE="replicated_host"

log() {
    echo "[INFO] $*"
}

configure_crush_rule() {
    log "Configuring CRUSH rule: $CRUSH_RULE"

    local rules
    rules="$(ceph osd crush rule ls --format json)"

    if ! jq -e --arg rule "$CRUSH_RULE" \
        'index($rule) != null' <<< "$rules" >/dev/null; then

        ceph osd crush rule create-replicated \
            "$CRUSH_RULE" default host
    fi
}

configure_rbd_pools() {
    local pools
    pools="$(ceph osd pool ls --format json)"

    for pool in "${CEPH_POOLS[@]}"; do
        if jq -e --arg pool "$pool" \
            'index($pool) != null' <<< "$pools" >/dev/null; then

            log "RBD pool already exists, skipping: $pool"
            continue
        fi

        log "Creating RBD pool: $pool"

        ceph osd pool create "$pool"
        ceph osd pool set "$pool" size "$REPLICA_SIZE"
        ceph osd pool set "$pool" min_size "$MIN_SIZE"
        ceph osd pool set "$pool" crush_rule "$CRUSH_RULE"
        ceph osd pool set "$pool" pg_autoscale_mode on

        ceph osd pool application enable "$pool" rbd
        rbd pool init "$pool"

        log "RBD pool created successfully: $pool"
    done
}

configure_ceph_auth() {
    log "Configuring CephX users for OpenStack"

    local user key decoded_size

    # Glance
    ceph auth get-or-create client.glance \
        mon 'profile rbd' \
        osd 'profile rbd pool=images' \
        mgr 'profile rbd pool=images' \
        >/dev/null

    # Cinder and Nova
    ceph auth get-or-create client.cinder \
        mon 'profile rbd' \
        osd 'profile rbd pool=volumes, profile rbd pool=vms, profile rbd-read-only pool=images' \
        mgr 'profile rbd pool=volumes, profile rbd pool=vms' \
        >/dev/null

    # Cinder Backup
    ceph auth get-or-create client.cinder-backup \
        mon 'profile rbd' \
        osd 'profile rbd pool=backups' \
        mgr 'profile rbd pool=backups' \
        >/dev/null

    # Validate CephX keys
    for user in glance cinder cinder-backup; do
        key="$(ceph auth get-key "client.${user}")"

        decoded_size="$(printf '%s' "${key}" | base64 -d | wc -c)"

        if [[ "${decoded_size}" -ne 16 ]]; then
            warn "Unexpected CephX key length for client.${user}: ${decoded_size} bytes"
        else
            log "CephX key validated: client.${user}"
        fi
    done
}

export_ceph_config() {
    log "Exporting Ceph configuration and keyrings"

    mkdir -p "$OUTPUT_DIR"
    chmod 700 "$OUTPUT_DIR"

    ceph config generate-minimal-conf > "$OUTPUT_DIR/ceph.conf"

    for user in glance cinder cinder-backup; do
        ceph auth get "client.$user" \
            -o "$OUTPUT_DIR/ceph.client.$user.keyring"
    done

    chmod 600 "$OUTPUT_DIR"/*.keyring

    log "Configuration exported to: $OUTPUT_DIR"
}

distribute_ceph_config() {
    log "Distributing Ceph configuration to deployment host"

    local infra_node="${INFRA_NODE:?ERROR: INFRA_NODE is not defined or is empty}"
    local private_key="${ADMIN_SSH_KEY:?ERROR: ADMIN_SSH_KEY is required}"
    local remote_dir="/etc/ceph"

    local files=(
        "ceph.conf"
        "ceph.client.glance.keyring"
        "ceph.client.cinder.keyring"
        "ceph.client.cinder-backup.keyring"
    )

    local ssh_opts=(
        -o StrictHostKeyChecking=no
        -o IdentityFile="$private_key"
        -o IdentitiesOnly=yes
        -o BatchMode=yes
    )

    # Validate exported files
    for file in "${files[@]}"; do
        if [[ ! -f "${OUTPUT_DIR}/${file}" ]]; then
            log "ERROR: Missing Ceph configuration: ${file}"
            return 1
        fi
    done

    ssh "${ssh_opts[@]}" "root@${infra_node}" \
        "mkdir -p '${remote_dir}' && chmod 700 '${remote_dir}'"

    scp "${ssh_opts[@]}" "${files[@]/#/${OUTPUT_DIR}/}" \
        "root@${infra_node}:${remote_dir}/"

    ssh "${ssh_opts[@]}" "root@${infra_node}" \
        "chmod 600 '${remote_dir}'/*.keyring && chmod 644 '${remote_dir}/ceph.conf'"

    log "Ceph configuration distributed to: ${infra_node}"
}

verify_ceph_rbd() {
    log "Verifying RBD pools"

    for pool in "${CEPH_POOLS[@]}"; do
        echo "========== $pool =========="

        ceph osd pool get "$pool" size
        ceph osd pool get "$pool" min_size
        ceph osd pool get "$pool" crush_rule
        ceph osd pool get "$pool" pg_autoscale_mode
    done

    log "Verifying CephX users"

    for user in glance cinder cinder-backup; do
        ceph auth get "client.$user" |
            sed '/^[[:space:]]*key[[:space:]]*=/d'
    done

    ceph -s
}

main() {
    configure_crush_rule
    configure_rbd_pools
    configure_ceph_auth
    export_ceph_config
    distribute_ceph_config
    verify_ceph_rbd

    log "Ceph RBD configuration completed successfully"
}

main "$@"