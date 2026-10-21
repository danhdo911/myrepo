#!/usr/bin/env bash

set -euo pipefail

sudo hostnamectl set-hostname migrator

sudo apt-get update

# Install essential packages
echo "Installing essential packages..."
sudo apt-get install -y \
    software-properties-common \
    make \
    git \
    curl \
    jq \
    tree

# Install Python packages required to build the Ansible Execution Environment
echo "Installing Python and ansible-builder..."
sudo apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    pipx

python3 -m pipx ensurepath
export PATH="$HOME/.local/bin:$PATH"

if command -v ansible-builder >/dev/null 2>&1; then
    echo "ansible-builder already installed: $(ansible-builder --version)"
else
    python3 -m pipx install ansible-builder
fi

if [[ -x "$HOME/.local/bin/ansible-builder" ]]; then
    sudo ln -sf "$HOME/.local/bin/ansible-builder" /usr/local/bin/ansible-builder
fi

echo "ansible-builder ready: $(ansible-builder --version)"

# Install Docker engine
echo "Installing docker engine... "
sudo apt-get install -y \
    ca-certificates \
    gnupg \
    lsb-release

sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | sudo gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg

sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

sudo apt-get update

sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

sudo systemctl enable --now docker

# Preparing sample environment
echo "Preparing sample environment files..."
mkdir -p environments
cp -r --update=none samples/sample_environment environments/sample_environment

# Output
echo
echo "Initial migrator setup completed successfully."
echo

exec bash
