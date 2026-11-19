#

## Preparation

```bash
## Prepare Ubuntu 24.04
sudo apt update
sudo apt install -y git sudo curl

sudo useradd -s /bin/bash -d /opt/stack -m stack

echo "stack ALL=(ALL) NOPASSWD: ALL" | \
  sudo tee /etc/sudoers.d/stack

sudo chmod 440 /etc/sudoers.d/stack
sudo chown -R stack:stack /opt/stack
sudo chmod 755 /opt/stack

## Clone OpenStack DevStack 2026.1
sudo su - stack

cd /opt/stack

git clone -b stable/2026.1 \
  https://opendev.org/openstack/devstack.git

cd devstack
git branch --show-current
```

## Configure `local.conf`

Create `/opt/stack/devstack/local.conf`

```bash
[[local|localrc]]

# OpenStack authentication
ADMIN_PASSWORD=openstack
DATABASE_PASSWORD=$ADMIN_PASSWORD
RABBIT_PASSWORD=$ADMIN_PASSWORD
SERVICE_PASSWORD=$ADMIN_PASSWORD

# IPv4 only
IP_VERSION=4

# Host networking
HOST_IP=172.16.85.98
SERVICE_HOST=$HOST_IP

# Public API DNS
PUBLIC_SERVICE_HOST=opsaio.dd-iaas.local

# Virtualization - No nested virtualization
LIBVIRT_TYPE=qemu

# Logs
LOGFILE=/opt/stack/logs/stack.sh.log
LOGDAYS=7
LOG_COLOR=False

# Reclone service repositories
RECLONE=yes
```

## Deploy

```bash
cd /opt/stack/devstack
./stack.sh
```

```bash
source /opt/stack/devstack/openrc admin admin

openstack compute service list
openstack hypervisor list
openstack network list
openstack volume service list

openstack resource class show MEMORY_MB
openstack resource provider list
```

## Rebuild

```bash
cd /opt/stack/devstack

# Stop existing deployment
./unstack.sh

# Clean existing DevStack resources
./clean.sh

# Switch release
git fetch origin
git switch stable/2026.1
git pull --ff-only

# Deploy
./stack.sh
```

## Custom login page

```bash
sudo -u stack nano /opt/stack/horizon/openstack_dashboard/templates/auth/_splash.html
```

```html
{% load themes %}

<div class="text-center">
  <!--
  <img class="splash-logo" src={% themable_asset "img/logo-splash.svg" %}>
  -->

  <h1 style="text-align: center; font-size: 36px; font-weight: 700;">
    Private Cloud
  </h1>
</div>

```

```bash
nano /opt/stack/horizon/openstack_dashboard/templates/header/_brand.html
```

```html
{% load branding %}
{% load themes %}

<a class="navbar-brand" href="{% site_branding_link %}" target="_self">
  {% comment %}
  <img class="openstack-logo" src="{% themable_asset 'img/logo.svg' %}" alt="{% site_branding %}">
  {% endcomment %}
  <span style="font-size: 20px; font-weight: 700; color: white;">
    Private Cloud
  </span>
</a>
```

```bash
systemctl restart apache2
```
