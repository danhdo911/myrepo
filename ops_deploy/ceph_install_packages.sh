#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() {
    echo "[INFO] $*"
}

warn() {
    echo "[WARN] $*" >&2
}

fail() {
    echo "[ERROR] $*" >&2
    exit 1
}

# Load environment configuration
if [[ -f "${SCRIPT_DIR}/.env" ]]; then
    set -a
    source "${SCRIPT_DIR}/.env"
    set +a
fi

# Configuration
CEPH_RELEASE="${CEPH_RELEASE:-tentacle}"
CEPH_VERSION="${CEPH_VERSION:-20.2.4}"
CEPH_IMAGE="${CEPH_IMAGE:-quay.io/ceph/ceph:v${CEPH_VERSION}}"
CEPH_INSTALL_COMMON="${CEPH_INSTALL_COMMON:-false}"
CEPHADM_PATH="/usr/local/sbin/cephadm"

check_prerequisites() {
    log "Checking Ceph installation prerequisites..."

    [[ "${EUID}" -eq 0 ]] || fail "This script must run as root."

    . /etc/os-release
    [[ "${ID}" == "ubuntu" ]] || fail "Only Ubuntu is supported."

    command -v docker >/dev/null 2>&1 ||
        fail "Docker Engine is not installed."

    docker info >/dev/null 2>&1 ||
        fail "Docker daemon is not running or accessible."

    log "Operating system: ${PRETTY_NAME}"
    log "Docker Engine: $(docker --version)"
}

install_dependencies() {
    log "Installing Cephadm prerequisites..."

    apt-get update

    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        curl \
        ca-certificates \
        python3 \
        lvm2
}

install_cephadm() {
    local cephadm_url
    local temp_file

    cephadm_url="https://download.ceph.com/rpm-${CEPH_VERSION}/el9/noarch/cephadm"
    temp_file="$(mktemp)"

    log "Downloading Cephadm v${CEPH_VERSION}..."

    if ! curl -fsSL --retry 3 \
        "${cephadm_url}" \
        -o "${temp_file}"; then
        rm -f "${temp_file}"
        fail "Failed to download Cephadm v${CEPH_VERSION}."
    fi

    install -m 0755 "${temp_file}" "${CEPHADM_PATH}"
    rm -f "${temp_file}"

    log "Cephadm installed: ${CEPHADM_PATH}"
}

configure_ceph_repository() {
    log "Configuring Ceph v${CEPH_VERSION} repository..."

    "${CEPHADM_PATH}" add-repo --version "${CEPH_VERSION}"

    apt-get update
}

install_ceph_common() {
    if [[ "${CEPH_INSTALL_COMMON}" != "true" ]]; then
        log "Skipping ceph-common installation."
        return
    fi

    log "Installing ceph-common..."

    "${CEPHADM_PATH}" install ceph-common
}

verify_installation() {
    log "Verifying Ceph installation..."

    echo "----------------------------------------"
    echo "Ceph Release : ${CEPH_RELEASE}"
    echo "Ceph Version : ${CEPH_VERSION}"
    echo "Ceph Image   : ${CEPH_IMAGE}"
    echo "Docker       : $(docker --version)"

    if [[ -x "${CEPHADM_PATH}" ]]; then
        echo "Cephadm      : Installed"
        "${CEPHADM_PATH}" version
    else
        echo "Cephadm      : Not installed"
    fi

    if command -v ceph >/dev/null 2>&1; then
        echo "Ceph CLI     : $(ceph --version)"
    else
        echo "Ceph CLI     : Not installed"
    fi

    echo "----------------------------------------"
}

main() {
    log "Starting Ceph ${CEPH_RELEASE} v${CEPH_VERSION} installation..."

    check_prerequisites
    install_dependencies
    install_cephadm
    configure_ceph_repository
    install_ceph_common
    verify_installation

    log "Ceph installation completed successfully."
}

main "$@"