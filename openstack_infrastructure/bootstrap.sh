#!/usr/bin/env bash

set -euo pipefail

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

# Install Vault CLI
echo "Installing Vault CLI..."

curl -fsSL https://apt.releases.hashicorp.com/gpg | \
    sudo gpg --dearmor --yes -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com \
$(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null

sudo apt-get update
sudo apt-get install -y vault

# # Install AWS CLI and MFA tools
# echo "Installing AWS CLI and MFA tools... "
# sudo apt-get install -y \
#     aws-cli \
#     oath-toolkit-oathtool

# Preparing local environment
echo "Preparing local environment files..."
cp -n samples/sample.env .env
cp -n samples/sample.aws_config aws_config
cp -n samples/sample.aws_credentials aws_credentials
touch ansible_private_key
chmod 600 ansible_private_key

# Output
echo
echo "Installed tools:"
echo "  $(make --version | head -n1)"
echo "  $(git --version)"
echo "  $(docker --version)"
echo "  $(docker compose version)"
echo "  $(vault version | head -n1)"
# echo "  $(aws --version)"
# echo "  $(oathtool --version | head -n1)"
echo
echo "Bootstrap completed."
echo
echo "Next steps:"
echo "  1. Update .env file."
echo "  2. Update aws_config and aws_credentials files if using AWS S3 for Terraform State."
echo "  3. ./bootstrap_verify.sh"
echo "  4. make docker_pull"
echo "  5. make vault_get_sshkey"
