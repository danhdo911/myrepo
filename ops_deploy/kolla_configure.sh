#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() {
    echo "[INFO] $*"
}

kolla_ceph_configure() {
    log "Preparing Kolla-Ansible service configurations"

    local config_source="${SCRIPT_DIR}/kolla_ansible/config"
    local config_target="/etc/kolla/config"
    local ceph_source="/etc/ceph"

    # Ensure configuration directories exist
    mkdir -p \
        "${config_target}/nova" \
        "${config_target}/cinder/cinder-volume" \
        "${config_target}/cinder/cinder-backup" \
        "${config_target}/glance"

    # Copy custom Kolla-Ansible service configurations
    if [[ -d "$config_source" ]]; then
        log "Copying custom Kolla-Ansible configurations"

        mkdir -p "$config_target"
        cp -a "${config_source}/." "${config_target}/"

        log "Custom Kolla-Ansible configurations copied successfully"
    fi

    # Verify Ceph configuration
    if [[ ! -f "${ceph_source}/ceph.conf" ]]; then
        log "ERROR: Ceph configuration not found"
        return 1
    fi

    # Copy Ceph configuration
    log "Configuring Ceph integration"

    for service in nova cinder glance; do
        cp "${ceph_source}/ceph.conf" \
           "${config_target}/${service}/ceph.conf"
    done

    # Nova keyrings
    cp "${ceph_source}/ceph.client.cinder.keyring" \
       "${config_target}/nova/"

    # Cinder Volume keyring
    cp "${ceph_source}/ceph.client.cinder.keyring" \
       "${config_target}/cinder/cinder-volume/"

    # Cinder Backup keyrings
    cp "${ceph_source}/ceph.client.cinder.keyring" \
       "${config_target}/cinder/cinder-backup/"

    cp "${ceph_source}/ceph.client.cinder-backup.keyring" \
       "${config_target}/cinder/cinder-backup/"

    # Glance keyring
    cp "${ceph_source}/ceph.client.glance.keyring" \
       "${config_target}/glance/"

    # Remove leading tabs and spaces from Ceph configuration and keyring files
    find "${config_target}" -type f \
        \( -name "ceph.conf" -o -name "*.keyring" \) \
        -exec sed -i 's/^[[:space:]]*//' {} +

    # Secure Ceph keyring permissions
    find "${config_target}" -type f -name "*.keyring" \
        -exec chmod 600 {} +

    log "Kolla-Ansible service configuration completed"
}

main() {
    kolla_ceph_configure
}

main "$@"
