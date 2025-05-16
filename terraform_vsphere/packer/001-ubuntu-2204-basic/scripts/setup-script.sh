#!/bin/bash -ex
# echo 'Removing cloud-int networking...'
# rm /etc/netplan/50-cloud-init.yaml

# Empty machine-id
echo 'Empty machine-id...'
sudo truncate -s 0 /etc/machine-id
sudo rm /var/lib/dbus/machine-id
sudo ln -s /etc/machine-id /var/lib/dbus/machine-id 

sudo hostnamectl set-hostname ubuntu