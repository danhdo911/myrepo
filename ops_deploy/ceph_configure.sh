#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/.inventory"

DEPLOY_MON="${DEPLOY_MON:-true}"
DEPLOY_MGR="${DEPLOY_MGR:-true}"
DEPLOY_OSD="${DEPLOY_OSD:-false}"

# ============================================================
# Configuration
# ============================================================

# Ceph MON placement: 5 nodes
MON_HOSTS=(
    "$CONTROLLER_01"
    "$CONTROLLER_02"
    "$CONTROLLER_03"
    "$COMPUTE_01"
    "$COMPUTE_02"
)

# Ceph MGR placement: 2 nodes
MGR_HOSTS=(
    "$CONTROLLER_01"
    "$CONTROLLER_02"
)

# Ceph OSD placement: 6 nodes
OSD_HOSTS=(
    "$CONTROLLER_01"
    "$CONTROLLER_02"
    "$CONTROLLER_03"
    "$COMPUTE_01"
    "$COMPUTE_02"
    "$COMPUTE_03"
)

# OSD disk (must be dedicated and unused on every selected host)
OSD_DEVICES=(
    "/dev/sdb"
    "/dev/sdc"
    "/dev/sdd"
)

# ============================================================
# Helpers
# ============================================================

log() {
    echo "[INFO] $*"
}

# Retrieve registered Ceph hosts once
load_ceph_hosts() {
    CEPH_HOSTS_JSON="$(ceph orch host ls --format json)"
}

get_ceph_hostname() {
    local ip="$1"

    jq -er --arg ip "$ip" \
        '.[] | select(.addr == $ip) | .hostname' \
        <<< "$CEPH_HOSTS_JSON"
}

resolve_hosts() {
    local ip hostname

    for ip in "$@"; do
        if ! hostname="$(get_ceph_hostname "$ip")"; then
            echo "[ERROR] Host not registered in Ceph: $ip" >&2
            return 1
        fi

        printf '%s\n' "$hostname"
    done
}

# ============================================================
# Deploy MON
# ============================================================

deploy_mon() {
    log "Configuring 5 MON daemons..."

    local -a names=()
    local ip hostname

    for ip in "${MON_HOSTS[@]}"; do
        hostname="$(get_ceph_hostname "$ip")"
        names+=("$hostname")
    done

    ceph orch apply mon \
        --placement="${#names[@]} ${names[*]}"
}

# ============================================================
# Deploy MGR
# ============================================================

deploy_mgr() {
    log "Configuring 2 MGR daemons..."

    local -a names=()
    local ip hostname

    for ip in "${MGR_HOSTS[@]}"; do
        hostname="$(get_ceph_hostname "$ip")"
        names+=("$hostname")
    done

    ceph orch apply mgr \
        --placement="${#names[@]} ${names[*]}"
}

# ============================================================
# Deploy OSD
# ============================================================

deploy_osd() {
    log "Discovering OSD devices..."
    ceph orch device ls --wide --refresh

    local total_osds=$((${#OSD_HOSTS[@]} * ${#OSD_DEVICES[@]}))

    echo
    log "OSD hosts: ${#OSD_HOSTS[@]}"
    log "OSD disks per host: ${#OSD_DEVICES[@]}"
    log "Total OSDs to deploy: ${total_osds}"

    local confirmation
    read -r -p \
        "Deploy ${total_osds} OSDs? Type YES: " \
        confirmation

    if [[ "$confirmation" != "YES" ]]; then
        log "OSD deployment cancelled."
        return 0
    fi

    local ip hostname device

    for ip in "${OSD_HOSTS[@]}"; do
        hostname="$(get_ceph_hostname "$ip")"

        for device in "${OSD_DEVICES[@]}"; do
            log "Deploying OSD: ${hostname}:${device}"

            ceph orch daemon add osd "${hostname}:${device}"
        done
    done
}

# ============================================================
# Verification
# ============================================================

verify_ceph() {
    log "Ceph hosts:"
    ceph orch host ls

    log "MON daemons:"
    ceph orch ps --daemon-type mon

    log "MGR daemons:"
    ceph orch ps --daemon-type mgr

    log "OSD daemons:"
    ceph orch ps --daemon-type osd

    log "Cluster status:"
    ceph -s
}

# ============================================================
# Main
# ============================================================

main() {
    load_ceph_hosts

    [[ "$DEPLOY_MON" == "true" ]] && deploy_mon
    [[ "$DEPLOY_MGR" == "true" ]] && deploy_mgr
    [[ "$DEPLOY_OSD" == "true" ]] && deploy_osd

    verify_ceph
}

main "$@"
