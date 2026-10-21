#!/usr/bin/env bash

set -euo pipefail

VIRTUAL_ENV=${1:-"/root/workdir/openstack/os-venv"}
KOLLA_DIR=${2:-"/etc/kolla"}

# Source Kolla virtual environment
if [[ -f "${VIRTUAL_ENV}/bin/activate" ]]; then
    source "${VIRTUAL_ENV}/bin/activate"
else
    echo "ERROR: Kolla virtual environment not found: ${VIRTUAL_ENV}"
    exit 1
fi

# Source admin credentials
if [[ -f "${KOLLA_DIR}/admin-openrc.sh" ]]; then
  source "${KOLLA_DIR}/admin-openrc.sh"
else
  echo "ERROR: ${KOLLA_DIR}/admin-openrc.sh not found!"
  exit 1
fi

echo "========== OpenStack Health Check =========="
echo ""
echo "----- OpenStack Endpoints List-----"
openstack endpoint list || { echo "Failed to list endpoints"; exit 1; }

# echo ""
# echo "----- OpenStack Services List -----"
# openstack service list || { echo "Failed to list services"; exit 1; }

# echo ""
# echo "----- Nova Compute Services -----"
# openstack compute service list || { echo "Failed to list compute services"; exit 1; }

# echo ""
# echo "----- Neutron Network Agents -----"
# openstack network agent list || { echo "Failed to list network agents"; exit 1; }

# echo ""
# echo "----- Cinder Volume Services -----"
# openstack volume service list || { echo "Failed to list volume services"; exit 1; }

# echo ""
# echo "----- Cinder Pools -----"
# cinder get-pools || { echo "Failed to get cinder pools"; exit 1; }

# echo ""
# echo "✅ All checks completed."

echo ""
echo "----- Cinder Pools Available -----"
cinder get-pools || { echo "Failed to get cinder pools"; exit 1; }

echo ""
echo "----- OpenStack Services State -----"
result=0

services=('compute' 'volume')
for s in "${services[@]}"; do
    openstack $s service list
    if ! openstack $s service list -f value -c Binary -c Host -c Status -c State | awk '
    BEGIN { bad=0 }
    { 
        if ($3!="enabled" || $4!="up") {
            bad=1;
            printf "%-30s %-25s %-10s %-10s\n", "Binary","Host","Status","State"
            printf "%-30s %-25s %-10s %-10s\n", $1,$2,$3,$4
        }
    }
    END {
        if (!bad)
            print "'${s^}' Services: ✅ All services are up and healthy."
        else
            print "'${s^}' Services: ❌ Some services are down or disabled."

        exit bad
    }'; then
        result=1
    fi

    echo ""
done

services=('network')
for s in "${services[@]}"; do
    openstack $s agent list
    if ! openstack $s agent list -f value -c Binary -c Host -c Alive -c State| awk '
    { if ($2!="True" || $3!="True") {
        bad=1;
        printf "%-30s %-25s %-10s %-10s\n", "Binary","Host","Alive","State"
        printf "%-30s %-25s %-10s %-10s\n", $4,$1,$2,$3
    }
    }
    END{
    if (!bad)
        print "'${s^}' Agents: ✅ All network agents are alive and healthy."
    else
        print "'${s^}' Agents: ❌ Some network agents are down or disabled."
    
    exit bad
    }'; then
        result=1
    fi

    echo ""
done

exit "$result"