#!/bin/bash -ex

#=========================== Setup ===========================
# echo "==> Set debconf to Noninteractive"
# echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections

# echo "==> Update packages list"
# sudo apt-get update

# echo "==> Upgradepacka list"
# sudo apt-get dist-upgrade -y

# echo "==> Installing common packages"
# sudo apt-get install -y \
#         openssh-server \
#         nano \
#         iputils-ping \
#         curl \
#         jq \
#         glances

#=========================== Post-setup ===========================
echo "==> Empty machine-id"
sudo truncate -s 0 /etc/machine-id
sudo rm /var/lib/dbus/machine-id
sudo ln -s /etc/machine-id /var/lib/dbus/machine-id 

echo "==> Remove the contents of /tmp and /var/tmp"
sudo rm -rf /tmp/* /var/tmp/*

echo "==> Truncate any logs that have built up during the install"
sudo find /var/log -type f -exec truncate --size=0 {} \;

echo "==> Cleanup bash history"
sudo rm -f ~/.bash_history

echo "remove /usr/share/doc/"
sudo rm -rf /usr/share/doc/*

echo "==> remove /var/cache"
sudo find /var/cache -type f -exec rm -rf {} \;

echo "==> Cleanup apt"
sudo apt-get -y autoremove
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*

echo '==> Removing cloud-int networking...'
sudo rm /etc/netplan/50-cloud-init.yaml

echo "==> Disable cloud-init network"
sudo mkdir -p /etc/cloud/cloud.cfg.d
sudo tee /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg > /dev/null <<EOF
network: {config: disabled}
EOF
