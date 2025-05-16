#!/bin/bash -ex
# echo 'Removing cloud-int networking...'
# rm /etc/netplan/50-cloud-init.yaml

# Empty machine-id
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
