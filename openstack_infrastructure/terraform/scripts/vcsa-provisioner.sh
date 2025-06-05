#!/bin/bash

i=0
while true; do
    if [ $i -le $TIMEOUT ]; then
        echo "Attempting to get vCenter Auth Token"
        if TOKEN=`curl -s -k -u ${VCENTER_USERNAME}:${VCENTER_PASSWORD} -X POST https://${VCENTER_HOSTNAME}/rest/com/vmware/cis/session | jq -r .value`; then
            echo "Attempting to get appliance system health status"
            
            if HEALTH=`curl -s -k -H "vmware-api-session-id: ${TOKEN}" -X GET https://${VCENTER_HOSTNAME}/rest/appliance/health/system | jq -r .value`; then
                if [ "${HEALTH}" = "green" ]; then
                    echo "vCenter Appliance healthy status is ${HEALTH}"
                    echo "vCenter Appliance provisioned succesfully"
                    break; fi
            fi
        fi
        echo "Unable to verify vCenter status, sleeping 1 minute"
        sleep 1m
        ((i++))
    else
        echo "Provisioner took over ${TIMEOUT} minutes.  Exiting with error"
        exit 1
    fi
done
    
exit 0