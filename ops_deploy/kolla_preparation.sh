#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "${SCRIPT_DIR}/.env" ]]; then
    set -a
    source "${SCRIPT_DIR}/.env"
    set +a
fi

# ============================================================
# Kolla-Ansible Environment Preparation
# ============================================================

WORKDIR="${WORKDIR:-/root/workdir}"
OPENSTACK_DIR="$WORKDIR/openstack"
VENV_DIR="$WORKDIR/openstack/os-venv"

KOLLA_VERSION="${KOLLA_VERSION:-stable/2026.1}"
ANSIBLE_CORE_VERSION="ansible-core>=2.19,<2.20.99"

KOLLA_CONFIG_DIR="/etc/kolla"
ANSIBLE_CONFIG_DIR="/etc/ansible"

log() {
    echo "[INFO] $*"
}

# ============================================================
# Install system dependencies
# ============================================================
install_dependencies() {
    log "Installing system dependencies"

    apt-get update

    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        python3 \
        python3-dev \
        python3-venv \
        python3-pip \
        build-essential \
        libffi-dev \
        libssl-dev \
        git \
        sshpass
}

# ============================================================
# Install Ansible Core and Kolla-Ansible
# ============================================================
install_kolla_ansible() {
    log "Creating Python virtual environment: $VENV_DIR"

    mkdir -p "$WORKDIR"

    if [[ ! -d "$VENV_DIR" ]]; then
        python3 -m venv "$VENV_DIR"
    fi

    "$VENV_DIR/bin/python" -m pip install --upgrade pip

    log "Installing Ansible Core: $ANSIBLE_CORE_VERSION"
    "$VENV_DIR/bin/python" -m pip install \
        "$ANSIBLE_CORE_VERSION"

    log "Installing Kolla-Ansible: $KOLLA_VERSION"
    "$VENV_DIR/bin/python" -m pip install \
        "git+https://opendev.org/openstack/kolla-ansible@${KOLLA_VERSION}"

    log "Installing Ansible Galaxy dependencies"
    PATH="$VENV_DIR/bin:$PATH" \
        "$VENV_DIR/bin/kolla-ansible" install-deps
}

# ============================================================
# Prepare Kolla-Ansible configuration
# ============================================================
prepare_kolla_config() {
    log "Preparing Kolla-Ansible configuration"

    local kolla_share="$VENV_DIR/share/kolla-ansible"

    if [[ ! -d "$kolla_share" ]]; then
        echo "[ERROR] Kolla-Ansible share directory not found: $kolla_share" >&2
        exit 1
    fi

    mkdir -p "$KOLLA_CONFIG_DIR"

    # Copy example configuration without overwriting existing files
    cp -r --update=none  \
        "$kolla_share/etc_examples/kolla/." \
        "$KOLLA_CONFIG_DIR/"

    log "Preparing multinode inventory"

    local inventory_source="${SCRIPT_DIR}/kolla_ansible/multinode"
    local inventory_target="${OPENSTACK_DIR}/multinode"

    if [[ ! -f "$inventory_target" ]]; then
        cp "$inventory_source" "$inventory_target"
    fi
}

# ============================================================
# Configure Ansible
# ============================================================
configure_ansible() {
    log "Configuring Ansible"

    mkdir -p "$ANSIBLE_CONFIG_DIR"

    if [[ ! -f "$ANSIBLE_CONFIG_DIR/ansible.cfg" ]]; then
        cat > "$ANSIBLE_CONFIG_DIR/ansible.cfg" <<EOF
[defaults]
host_key_checking = False
pipelining = True
forks = 100
callbacks_enabled = ansible.posix.profile_tasks
private_key_file = ${ADMIN_SSH_KEY}

[ssh_connection]
ssh_args = -C -o ControlMaster=auto -o ControlPersist=60s
EOF
    else
        log "Ansible configuration already exists, skipping"
    fi
}

# ============================================================
# Active Python environment
# ============================================================
configure_python_env() {
    log "Configuring automatic Python virtual environment activation"

    local activate_cmd="source $VENV_DIR/bin/activate"

    if ! grep -Fxq "$activate_cmd" /root/.bashrc; then
        echo "$activate_cmd" >> /root/.bashrc
    fi
}

# ============================================================
# Verify installation
# ============================================================
verify_installation() {
    log "Verifying Python version"
    "$VENV_DIR/bin/python" --version

    log "Verifying Ansible version"
    "$VENV_DIR/bin/ansible" --version

    log "Verifying Kolla-Ansible version"
    "$VENV_DIR/bin/kolla-ansible" --version

    log "Checking Python package dependencies"
    "$VENV_DIR/bin/python" -m pip check

    log "Checking configuration files"

    test -f "$KOLLA_CONFIG_DIR/globals.yml"
    test -f "$KOLLA_CONFIG_DIR/passwords.yml"
    test -f "$WORKDIR/multinode"
    test -f "$WORKDIR/multinode.bak"
    test -f "$ANSIBLE_CONFIG_DIR/ansible.cfg"

    log "Installation verification completed"
}

# ============================================================
# Main
# ============================================================
main() {
    if [[ "$EUID" -ne 0 ]]; then
        echo "[ERROR] Run this script as root" >&2
        exit 1
    fi

    #install_dependencies
    install_kolla_ansible
    prepare_kolla_config
    configure_ansible
    configure_python_env
    verify_installation

    log "Kolla-Ansible environment preparation completed"
}

main "$@"
