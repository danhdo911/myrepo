#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${OUTPUT_DIR:-${SCRIPT_DIR}/output/ceph}"

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
    log "Creating CephX users for OpenStack"

    # Glance
    if ceph auth get client.glance >/dev/null 2>&1; then
        log "CephX user already exists, skipping: client.glance"
    else
        ceph auth get-or-create client.glance \
            mon 'profile rbd' \
            osd 'profile rbd pool=images' \
            mgr 'profile rbd pool=images' \
            >/dev/null
    fi

    # Cinder and Nova
    if ceph auth get client.cinder >/dev/null 2>&1; then
        log "CephX user already exists, skipping: client.cinder"
    else
        ceph auth get-or-create client.cinder \
            mon 'profile rbd' \
            osd 'profile rbd pool=volumes, profile rbd pool=vms, profile rbd-read-only pool=images' \
            mgr 'profile rbd pool=volumes, profile rbd pool=vms' \
            >/dev/null
    fi

    # Cinder Backup
    if ceph get client.cinder-backup >/dev/null 2>&1; then
        log "CephX user already exists, skipping: client.cinder-backup"
    else
        ceph auth get-or-create client.cinder-backup \
            mon 'profile rbd' \
            osd 'profile rbd pool=backups' \
            mgr 'profile rbd pool=backups' \
            >/dev/null
    fi
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
    verify_ceph_rbd

    log "Ceph RBD configuration completed successfully"
}

main "$@"