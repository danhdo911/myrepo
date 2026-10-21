#!/usr/bin/env bash

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

CENTOS_IMAGE_FILE="${CENTOS_IMAGE_FILE:-CentOS-Stream-GenericCloud-10-20260630.0.x86_64.qcow2}"
CENTOS_IMAGE_URL="${CENTOS_IMAGE_URL:-https://cloud.centos.org/centos/10-stream/x86_64/images/${CENTOS_IMAGE_FILE}}"
CONVERSION_IMAGE_DIR="${CONVERSION_IMAGE_DIR:-/tmp/os-migrate-images}"
CONVERSION_IMAGE_NAME="${CONVERSION_IMAGE_NAME:-${CENTOS_IMAGE_FILE}}"

CONVERSION_HOST_NAME="${CONVERSION_HOST_NAME:-vmware-conv-host}"
CONVERSION_BOOT_DISK_GB="${CONVERSION_BOOT_DISK_GB:-100}"
CONVERSION_FLAVOR_NAME="${CONVERSION_FLAVOR_NAME:-vmware-conv-host}"
CONVERSION_FLAVOR_VCPUS="${CONVERSION_FLAVOR_VCPUS:-6}"
CONVERSION_FLAVOR_RAM_MB="${CONVERSION_FLAVOR_RAM_MB:-12288}"

CONVERSION_NETWORK="${CONVERSION_NETWORK:-}"
CONVERSION_STATIC_IP="${CONVERSION_STATIC_IP:-${CONVERSION_FIXED_IP:-}}"
CONVERSION_SECURITY_GROUP_NAME="${CONVERSION_SECURITY_GROUP_NAME:-vmware-conv-host}"

CONVERSION_KEY_NAME="${CONVERSION_KEY_NAME:-vmware-conv-host}"
CONVERSION_PUBLIC_KEY_FILE="${CONVERSION_PUBLIC_KEY_FILE:-${HOME}/.ssh/vmware-conv-host.pub}"
CONVERSION_PRIVATE_KEY_FILE="${CONVERSION_PUBLIC_KEY_FILE%.pub}"

CONVERSION_FLOATING_IP="${CONVERSION_FLOATING_IP:-}"
CONVERSION_FLOATING_NETWORK="${CONVERSION_FLOATING_NETWORK:-}"
CONVERSION_WAIT="${CONVERSION_WAIT:-true}"

usage() {
    cat <<EOF
Usage:
  CONVERSION_NETWORK=<network> ${0}

Required:
  CONVERSION_NETWORK              OpenStack network name or ID for the conversion host.

Optional:
  ENV_FILE                        Environment file to source. Default: ${ENV_FILE}
  CENTOS_IMAGE_FILE               Image file name. Default: ${CENTOS_IMAGE_FILE}
  CENTOS_IMAGE_URL                Image download URL. Default: ${CENTOS_IMAGE_URL}
  CONVERSION_IMAGE_DIR            Local download directory. Default: ${CONVERSION_IMAGE_DIR}
  CONVERSION_IMAGE_NAME           OpenStack image name. Default: ${CONVERSION_IMAGE_NAME}
  CONVERSION_HOST_NAME            Server name. Default: ${CONVERSION_HOST_NAME}
  CONVERSION_BOOT_DISK_GB         Boot disk in GB. Default: ${CONVERSION_BOOT_DISK_GB}
  CONVERSION_FLAVOR_NAME          Flavor name. Default: ${CONVERSION_FLAVOR_NAME}
  CONVERSION_FLAVOR_VCPUS         Flavor vCPUs. Default: ${CONVERSION_FLAVOR_VCPUS}
  CONVERSION_FLAVOR_RAM_MB        Flavor RAM in MB. Default: ${CONVERSION_FLAVOR_RAM_MB}
  CONVERSION_STATIC_IP            Fixed IP address for the conversion host.
  CONVERSION_KEY_NAME             Keypair name. Default: ${CONVERSION_KEY_NAME}
  CONVERSION_PRIVATE_KEY_FILE     Private key file to create when public key is missing. Default: ${CONVERSION_PRIVATE_KEY_FILE}
  CONVERSION_PUBLIC_KEY_FILE      Public key file to create keypair if missing. Default: ${CONVERSION_PUBLIC_KEY_FILE}
  CONVERSION_SECURITY_GROUP_NAME  Security group name. Default: ${CONVERSION_SECURITY_GROUP_NAME}
  CONVERSION_FLOATING_IP          Existing floating IP to attach.
  CONVERSION_FLOATING_NETWORK     External network to allocate a floating IP when CONVERSION_FLOATING_IP is unset.
  CONVERSION_WAIT                 Wait for server creation. Default: ${CONVERSION_WAIT}
EOF
}

log() {
    echo "[INFO] $*"
}

fail() {
    echo "[ERROR] $*" >&2
    exit 1
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || fail "Required command not found: $1"
}

ensure_local_keypair() {
    if [[ -s "$CONVERSION_PUBLIC_KEY_FILE" ]]; then
        log "Local public key already exists: $CONVERSION_PUBLIC_KEY_FILE"
        return
    fi

    require_command ssh-keygen
    mkdir -p "$(dirname "$CONVERSION_PUBLIC_KEY_FILE")"

    if [[ -s "$CONVERSION_PRIVATE_KEY_FILE" ]]; then
        log "Creating public key from existing private key: $CONVERSION_PRIVATE_KEY_FILE"
        ssh-keygen -y -f "$CONVERSION_PRIVATE_KEY_FILE" > "$CONVERSION_PUBLIC_KEY_FILE"
    else
        log "Creating local SSH keypair on migrator: $CONVERSION_PRIVATE_KEY_FILE"
        ssh-keygen \
            -t ed25519 \
            -N "" \
            -C "$CONVERSION_KEY_NAME" \
            -f "$CONVERSION_PRIVATE_KEY_FILE" >/dev/null
    fi

    chmod 600 "$CONVERSION_PRIVATE_KEY_FILE"
    chmod 644 "$CONVERSION_PUBLIC_KEY_FILE"
}

validate_inputs() {
    [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && {
        usage
        exit 0
    }

    [[ -n "$CONVERSION_NETWORK" ]] || {
        usage
        fail "CONVERSION_NETWORK is required."
    }
}

validate_openstack_auth() {
    log "Checking OpenStack authentication..."
    openstack token issue >/dev/null || fail "OpenStack authentication failed. Check OS_* variables or ENV_FILE."
}

download_image() {
    local image_path="$1"

    mkdir -p "$CONVERSION_IMAGE_DIR"

    if [[ -s "$image_path" ]]; then
        log "Image already downloaded: $image_path"
        return
    fi

    log "Downloading image: $CENTOS_IMAGE_URL"
    curl --fail --location --insecure --retry 3 --output "$image_path" "$CENTOS_IMAGE_URL"
}

ensure_openstack_image() {
    local image_path="$1"

    if openstack image show "$CONVERSION_IMAGE_NAME" >/dev/null 2>&1; then
        log "OpenStack image already exists: $CONVERSION_IMAGE_NAME"
        return
    fi

    log "Uploading OpenStack image: $CONVERSION_IMAGE_NAME"
    openstack image create \
        --disk-format qcow2 \
        --container-format bare \
        --file "$image_path" \
        --property os_type=linux \
        --property os_distro=centos \
        "$CONVERSION_IMAGE_NAME" >/dev/null

    wait_for_image
}

wait_for_image() {
    local status

    log "Waiting for image to become active..."
    for _ in {1..60}; do
        status="$(openstack image show "$CONVERSION_IMAGE_NAME" -f value -c status 2>/dev/null || true)"
        [[ "$status" == "active" ]] && return
        sleep 5
    done

    fail "Image did not become active: $CONVERSION_IMAGE_NAME"
}

ensure_flavor() {
    if openstack flavor show "$CONVERSION_FLAVOR_NAME" >/dev/null 2>&1; then
        log "Flavor already exists: $CONVERSION_FLAVOR_NAME"
        return
    fi

    log "Creating flavor: $CONVERSION_FLAVOR_NAME"
    openstack flavor create \
        --vcpus "$CONVERSION_FLAVOR_VCPUS" \
        --ram "$CONVERSION_FLAVOR_RAM_MB" \
        --disk 0 \
        "$CONVERSION_FLAVOR_NAME" >/dev/null
}

ensure_network() {
    log "Checking network: $CONVERSION_NETWORK"
    openstack network show "$CONVERSION_NETWORK" >/dev/null || fail "OpenStack network not found: $CONVERSION_NETWORK"
}

ensure_keypair() {
    if openstack keypair show "$CONVERSION_KEY_NAME" >/dev/null 2>&1; then
        log "Keypair already exists: $CONVERSION_KEY_NAME"
        return
    fi

    ensure_local_keypair

    log "Creating keypair: $CONVERSION_KEY_NAME"
    openstack keypair create \
        --public-key "$CONVERSION_PUBLIC_KEY_FILE" \
        "$CONVERSION_KEY_NAME" >/dev/null
}

ensure_security_group() {
    if openstack security group show "$CONVERSION_SECURITY_GROUP_NAME" >/dev/null 2>&1; then
        log "Security group already exists: $CONVERSION_SECURITY_GROUP_NAME"
        return
    fi

    log "Creating security group: $CONVERSION_SECURITY_GROUP_NAME"
    openstack security group create \
        --description "Security group for VMware conversion host" \
        "$CONVERSION_SECURITY_GROUP_NAME" >/dev/null

    openstack security group rule create \
        --proto tcp \
        --dst-port 22 \
        "$CONVERSION_SECURITY_GROUP_NAME" >/dev/null

    openstack security group rule create \
        --proto icmp \
        "$CONVERSION_SECURITY_GROUP_NAME" >/dev/null
}

ensure_server() {
    local create_args
    create_args=(
        server create
        --boot-from-volume "$CONVERSION_BOOT_DISK_GB"
        --flavor "$CONVERSION_FLAVOR_NAME"
        --image "$CONVERSION_IMAGE_NAME"
        --key-name "$CONVERSION_KEY_NAME"
        --security-group "$CONVERSION_SECURITY_GROUP_NAME"
    )

    if [[ -n "$CONVERSION_STATIC_IP" ]]; then
        local network_id
        network_id="$(openstack network show "$CONVERSION_NETWORK" -f value -c id)"
        create_args+=(--nic "net-id=${network_id},v4-fixed-ip=${CONVERSION_STATIC_IP}")
    else
        create_args+=(--network "$CONVERSION_NETWORK")
    fi

    [[ "$CONVERSION_WAIT" == "true" ]] && create_args+=(--wait)

    if openstack server show "$CONVERSION_HOST_NAME" >/dev/null 2>&1; then
        log "Conversion host already exists: $CONVERSION_HOST_NAME"
        return
    fi

    log "Creating conversion host: $CONVERSION_HOST_NAME"
    openstack "${create_args[@]}" "$CONVERSION_HOST_NAME"
}

ensure_floating_ip() {
    local server_addresses

    [[ -n "$CONVERSION_FLOATING_IP" || -n "$CONVERSION_FLOATING_NETWORK" ]] || {
        log "No floating IP requested. Skipping floating IP assignment."
        return
    }

    server_addresses="$(openstack server show "$CONVERSION_HOST_NAME" -f value -c addresses)"

    if [[ -n "$CONVERSION_FLOATING_IP" && "$server_addresses" == *"$CONVERSION_FLOATING_IP"* ]]; then
        log "Floating IP already attached: $CONVERSION_FLOATING_IP"
        return
    fi

    if [[ -z "$CONVERSION_FLOATING_IP" ]]; then
        log "Allocating floating IP from network: $CONVERSION_FLOATING_NETWORK"
        CONVERSION_FLOATING_IP="$(
            openstack floating ip create \
                "$CONVERSION_FLOATING_NETWORK" \
                -f value \
                -c floating_ip_address
        )"
    elif ! openstack floating ip show "$CONVERSION_FLOATING_IP" >/dev/null 2>&1; then
        [[ -n "$CONVERSION_FLOATING_NETWORK" ]] || fail "Floating IP does not exist and CONVERSION_FLOATING_NETWORK is unset: $CONVERSION_FLOATING_IP"

        log "Allocating requested floating IP: $CONVERSION_FLOATING_IP"
        openstack floating ip create \
            --floating-ip-address "$CONVERSION_FLOATING_IP" \
            "$CONVERSION_FLOATING_NETWORK" >/dev/null
    fi

    log "Attaching floating IP: $CONVERSION_FLOATING_IP"
    openstack server add floating ip "$CONVERSION_HOST_NAME" "$CONVERSION_FLOATING_IP"
}

main() {
    validate_inputs "${1:-}"
    require_command curl
    require_command openstack
    validate_openstack_auth

    local image_path="${CONVERSION_IMAGE_DIR}/${CENTOS_IMAGE_FILE}"

    download_image "$image_path"
    ensure_openstack_image "$image_path"
    ensure_flavor
    ensure_network
    ensure_keypair
    ensure_security_group
    ensure_server
    ensure_floating_ip

    echo
    log "Conversion host is ready."
    openstack server show "$CONVERSION_HOST_NAME"
}

main "$@"
