
#!/bin/bash

# Extract the interface (first argument)
INTERFACE=${1:?Please input interface name.}
shift

# Check that at least one IP was provided
: "${1:?Please input at least one IP address.}"

# Store validation results
RESULTS=()

# Find and validate gateway
GATEWAY_IP=$(ip route show dev "$INTERFACE" | awk '/default/ {print $3; exit}')
: "${GATEWAY_IP:?Error: Could not automatically detect a gateway}"

echo "========================================"
echo "Testing Gateway: $GATEWAY_IP on $INTERFACE"
echo "========================================"

if ping -c 4 -I "$INTERFACE" "$GATEWAY_IP"; then
    RESULTS+=("$INTERFACE|$GATEWAY_IP|PASS")
else
    RESULTS+=("$INTERFACE|$GATEWAY_IP|FAIL")
fi

# Determine packet size
if [[ "$INTERFACE" == "ens33" || "$INTERFACE" == "ens34" ]]; then
    MTU_SIZE=1472
    echo -e "\nUsing standard MTU 1500 (-s 1472)."
else
    MTU_SIZE=8972
    echo -e "\nUsing Jumbo Frame MTU 9000 (-s 8972)."
fi

# Validate target IPs
for IP in "$@"; do
    echo "----------------------------------------"
    echo "Testing MTU for target IP: $IP"
    echo "----------------------------------------"

    if ping -c 4 -I "$INTERFACE" "$IP" -M do -s "$MTU_SIZE"; then
        RESULTS+=("$INTERFACE|$IP|PASS")
    else
        RESULTS+=("$INTERFACE|$IP|FAIL")
    fi
done

# Summary report
echo
echo "========================================"
echo "       NETWORK VALIDATION SUMMARY"
echo "========================================"

printf "%-15s %-20s %-10s\n" "INTERFACE" "IP ADDRESS" "STATE"
printf "%-15s %-20s %-10s\n" "---------" "----------" "-----"

FAILED=0

for RESULT in "${RESULTS[@]}"; do
    IFS='|' read -r IFACE IP STATE <<< "$RESULT"
    printf "%-15s %-20s %-10s\n" "$IFACE" "$IP" "$STATE"

    if [[ "$STATE" == "FAIL" ]]; then
        FAILED=$((FAILED + 1))
    fi
done

echo "========================================"
echo "Total: ${#RESULTS[@]} | Passed: $((${#RESULTS[@]} - FAILED)) | Failed: $FAILED"

if (( FAILED > 0 )); then
    exit 1
fi

exit 0
