#!/bin/bash
i=0

while true; do
    if [ "$i" -le "$TIMEOUT" ]; then
        echo "⏳ Waiting to connect to vCD..."

        # Check vCD API availability
        if curl -ksSL -X POST "https://${VCD_HOSTNAME}/cloudapi/1.0.0/sessions/provider" \
            -H "Accept: application/json;version=${VCD_API_VERSION}" \
            -u "${VCD_USERNAME}:${VCD_PASSWORD}" \
            -w "%{http_code}" -o /dev/null | grep -q "200"; then

            echo "✅ HTTP status is 200: OK"
            echo "🔑 Exporting vCD Authenticate Token..."

            # Get authentication token
            VCD_AUTH_TOKEN=$(curl -ksSL -D - -X POST "https://${VCD_HOSTNAME}/cloudapi/1.0.0/sessions/provider" \
                -H "Accept: application/json;version=${VCD_API_VERSION}" \
                -u "${VCD_USERNAME}:${VCD_PASSWORD}" | grep -i "X-VMWARE-VCLOUD-ACCESS-TOKEN" | awk '{print $2}' | tr -d '\r')

            if [ -z "$VCD_AUTH_TOKEN" ]; then
                echo "❌ Failed to retrieve vCD authentication token!"
                exit 1
            fi

            echo "🔍 Checking vCD Cell status..."

            # Fetch vCD cell status
            VCD_CELL_RESPONSE=$(curl -ksSL -X GET "https://${VCD_HOSTNAME}/cloudapi/1.0.0/cells" \
            -H "Authorization: Bearer ${VCD_AUTH_TOKEN}" \
            -H "Accept: application/json;version=${VCD_API_VERSION}")

            # Extract cell status from JSON response
            VCD_CELL_STATUS=$(echo "$VCD_CELL_RESPONSE" | jq -r '.values[0].status')

            if [ "$VCD_CELL_STATUS" = "ACTIVE" ]; then
                echo "✅ vCloud Director Cell is healthy: ${VCD_CELL_STATUS}"
                echo "✅ vCloud Director Appliance provisioned successfully!"
                break
            else
                echo "⚠️ vCloud Director Cell status is '${VCD_CELL_STATUS}', retrying..."
            fi
        fi    

        echo "⏳ Unable to verify vCloud Director Cell status, sleeping 1 minute..."
        sleep 1m
        ((i++))
    else
        echo "❌ Provisioning took over ${TIMEOUT} minutes. Exiting with error."
        exit 1
    fi
done

exit 0