#!/bin/bash

echo "========== OpenStack Post-Deployment Checks =========="

# Source admin credentials
if [[ -f /etc/kolla/admin-openrc.sh ]]; then
  source /etc/kolla/admin-openrc.sh
else
  echo "ERROR: /etc/kolla/admin-openrc.sh not found!"
  exit 1
fi

echo ""
echo "----- OpenStack Endpoints -----"
openstack endpoint list || { echo "Failed to list endpoints"; exit 1; }

echo ""
echo "----- OpenStack Services -----"
openstack service list || { echo "Failed to list services"; exit 1; }

echo ""
echo "----- Nova Compute Services -----"
openstack compute service list || { echo "Failed to list compute services"; exit 1; }

echo ""
echo "----- Neutron Network Agents -----"
openstack network agent list || { echo "Failed to list network agents"; exit 1; }

echo ""
echo "----- Cinder Volume Services -----"
openstack volume service list || { echo "Failed to list volume services"; exit 1; }

echo ""
echo "----- Cinder Pools -----"
cinder get-pools || { echo "Failed to get cinder pools"; exit 1; }

echo ""
echo "✅ All checks completed."
