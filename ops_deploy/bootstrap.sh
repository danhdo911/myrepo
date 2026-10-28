#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() {
    echo "[INFO] $*"
}

fail() {
    echo "[ERROR] $*" >&2
    exit 1
}

# Load configuration
if [[ -f "${SCRIPT_DIR}/.env" ]]; then
    set -a
    source "${SCRIPT_DIR}/.env"
    set +a
fi

source "${SCRIPT_DIR}/bootstrap_packages.conf"

# Defaults
HOSTNAME_OVERRIDE="${HOSTNAME_OVERRIDE:-openstack01}"
DOMAIN="${DOMAIN}"
TIMEZONE="${TIMEZONE:-Asia/Ho_Chi_Minh}"
NTP_SERVERS="${NTP_SERVERS:-0.pool.ntp.org 1.pool.ntp.org}"

CONFIGURE_HOSTNAME="${CONFIGURE_HOSTNAME:-true}"
CONFIGURE_TIMEZONE="${CONFIGURE_TIMEZONE:-true}"
CONFIGURE_NTP="${CONFIGURE_NTP:-true}"
DISABLE_CLOUD_INIT="${DISABLE_CLOUD_INIT:-false}"
DISABLE_FIREWALL="${DISABLE_FIREWALL:-false}"

INSTALL_COMMON="${INSTALL_COMMON:-true}"
INSTALL_OPENSTACK="${INSTALL_OPENSTACK:-true}"
INSTALL_CEPH="${INSTALL_CEPH:-false}"
INSTALL_PYTHON="${INSTALL_PYTHON:-true}"

# --------------------------------------------------
# System configuration
# --------------------------------------------------

configure_hostname() {
    local fqdn="${HOSTNAME_OVERRIDE}"

    if [[ -n "${DOMAIN:-}" ]]; then
        fqdn="${HOSTNAME_OVERRIDE}.${DOMAIN}"
    fi

    log "Configuring hostname: ${fqdn}..."

    hostnamectl set-hostname "${fqdn}"

    # Update /etc/hosts for local hostname resolution
    if grep -qE '^127\.0\.1\.1[[:space:]]' /etc/hosts; then
        sed -i -E \
            "s/^127\.0\.1\.1[[:space:]].*/127.0.1.1 ${fqdn} ${HOSTNAME_OVERRIDE}/" \
            /etc/hosts
    else
        echo "127.0.1.1 ${fqdn} ${HOSTNAME_OVERRIDE}" >> /etc/hosts
    fi

    log "Hostname configured successfully."
}

configure_timezone() {
    log "Configuring timezone: ${TIMEZONE}..."
    timedatectl set-timezone "${TIMEZONE}"
}

configure_ntp() {
    log "Configuring NTP servers: ${NTP_SERVERS}..."

    DEBIAN_FRONTEND=noninteractive apt-get install -y chrony

    mkdir -p /etc/chrony/sources.d

    {
        for server in ${NTP_SERVERS}; do
            echo "server ${server} iburst"
        done
    } > /etc/chrony/sources.d/bootstrap.sources

    if ! grep -qE \
        '^[[:space:]]*sourcedir[[:space:]]+/etc/chrony/sources.d' \
        /etc/chrony/chrony.conf; then
        echo "sourcedir /etc/chrony/sources.d" >> /etc/chrony/chrony.conf
    fi

    systemctl enable --now chrony
    systemctl restart chrony
}

disable_cloud_init() {
    log "Disabling cloud-init..."
    touch /etc/cloud/cloud-init.disabled
}

disable_firewall() {
    log "Disabling UFW firewall..."

    if command -v ufw >/dev/null 2>&1; then
        ufw --force disable
    fi
}

# --------------------------------------------------
# Package installation
# --------------------------------------------------

install_packages() {
    local group="$1"
    shift

    log "Installing ${group} packages..."

    DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
}

configure_packages() {
    log "Updating APT package index..."
    apt-get update

    if [[ "${INSTALL_COMMON}" == "true" ]]; then
        install_packages "common" "${COMMON_PACKAGES[@]}"
    fi

    if [[ "${INSTALL_OPENSTACK}" == "true" ]]; then
        install_packages "OpenStack" "${OPENSTACK_PACKAGES[@]}"
    fi

    if [[ "${INSTALL_CEPH}" == "true" ]]; then
        install_packages "Ceph" "${CEPH_PACKAGES[@]}"
    fi

    if [[ "${INSTALL_PYTHON}" == "true" ]]; then
        install_packages "Python" "${PYTHON_PACKAGES[@]}"
    fi
}

install_docker_packages() {

    # Install Docker GPG key
    install -m 0755 -d /etc/apt/keyrings

    curl -fsSL --retry 3 \
        https://download.docker.com/linux/ubuntu/gpg \
        -o /etc/apt/keyrings/docker.asc

    chmod 0644 /etc/apt/keyrings/docker.asc

    # Configure official Docker repository
    tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

    log "Updating Docker package index..."
    apt-get update

    local docker_packages=(
        docker-ce
        docker-ce-cli
        containerd.io
        docker-buildx-plugin
        docker-compose-plugin
    )

    if [[ -n "${DOCKER_VERSION:-}" ]]; then
        log "Installing Docker Engine version: ${DOCKER_VERSION}..."

        docker_packages=(
            "docker-ce=${DOCKER_VERSION}"
            "docker-ce-cli=${DOCKER_VERSION}"
            containerd.io
            docker-buildx-plugin
            docker-compose-plugin
        )
    else
        log "Installing the latest available Docker Engine..."
    fi

    DEBIAN_FRONTEND=noninteractive apt-get install -y "${docker_packages[@]}"

    if [[ "${DOCKER_HOLD_VERSION:-false}" == "true" ]]; then
        log "Holding Docker package versions..."

        apt-mark hold \
            docker-ce \
            docker-ce-cli \
            containerd.io \
            docker-buildx-plugin \
            docker-compose-plugin
    fi
}

# --------------------------------------------------
# Bootstrap status
# --------------------------------------------------

show_system_status() {
    log "Checking system configuration..."

    echo "----------------------------------------"
    echo "Hostname    : $(hostname)"
    echo "Domain      : $(hostname -d)"
    echo "Timezone    : $(timedatectl show -p Timezone --value)"
    echo "NTP Enabled : $(timedatectl show -p NTP --value)"
    echo "NTP Sync    : $(timedatectl show -p NTPSynchronized --value)"

    echo "Chrony      : $(systemctl is-active chrony 2>/dev/null || true)"

    if command -v ufw >/dev/null 2>&1; then
        echo "Firewall    : $(ufw status | head -n 1)"
    else
        echo "Firewall    : Not installed (UFW)"
    fi

    if [[ -f /etc/cloud/cloud-init.disabled ]]; then
        echo "Cloud-init  : Disabled"
    elif command -v cloud-init >/dev/null 2>&1; then
        echo "Cloud-init  : $(cloud-init status 2>/dev/null || true)"
    else
        echo "Cloud-init  : Not installed"
    fi

    if command -v docker >/dev/null 2>&1; then
        echo "Docker        : $(docker --version)"
        echo "Docker Engine : $(systemctl is-active docker 2>/dev/null || true)"
        echo "Docker Compose: $(docker compose version --short 2>/dev/null || true)"
    else
        echo "Docker        : Not installed"
    fi

    echo "----------------------------------------"
}

# --------------------------------------------------
# Main
# --------------------------------------------------

main() {
    [[ "${EUID}" -eq 0 ]] || fail "This script must be run as root."

    log "Starting host bootstrap..."

    # System initialization
    [[ "${CONFIGURE_HOSTNAME}" == "true" ]] && configure_hostname
    [[ "${CONFIGURE_TIMEZONE}" == "true" ]] && configure_timezone
    [[ "${CONFIGURE_NTP}" == "true" ]] && configure_ntp
    [[ "${DISABLE_CLOUD_INIT}" == "true" ]] && disable_cloud_init
    [[ "${DISABLE_FIREWALL}" == "true" ]] && disable_firewall

    # Package installation
    configure_packages

    # Docker Engine installation
    if [[ "${INSTALL_DOCKER:-false}" == "true" ]]; then
        install_docker_packages
    fi

    show_system_status

    log "Host bootstrap completed successfully."
}

main "$@"