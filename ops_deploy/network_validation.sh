
#!/bin/bash

# Extract the interface (first argument)
INTERFACE=${1:? Please input interface name.}
shift # Remove interface from arguments, leaving only the IPs

# Check that at least one IP was provided
: "${1:? Please input at least one ip address.}"

# Store validation results
RESULTS=()

# Find and validate Gateway (Only runs ONCE)
GATEWAY_IP=$(ip route show dev "$INTERFACE" | grep static | awk '{print $3}')
: "${GATEWAY_IP:?Error: Could not automatically detect a gateway}"

echo "========================================"
echo "Testing Gateway ONCE: $GATEWAY_IP on $INTERFACE"
echo "========================================"
ping -c 4 -I "${INTERFACE}" "${GATEWAY_IP}"
RESULTS+=("$INTERFACE|$GATEWAY_IP|N/A|$?")

# Determine packet size based on the interface name
if [ "$INTERFACE" = "ens33" ] || [ "$INTERFACE" = "ens34" ]; then
    MTU_SIZE=1472
    echo -e "\nInterface is ens33. Using standard 1500 MTU size (-s 1472)."
else
    MTU_SIZE=8972
    echo -e "\nUsing Jumbo Frame 9000 MTU size (-s 8972)."
fi

# Loop through all remaining IP arguments
for IP in "$@"; do
    echo "----------------------------------------"
    echo "Testing MTU for target IP: $IP"
    echo "----------------------------------------"

    ping -c 4 -I "${INTERFACE}" "${IP}" -M do -s $MTU_SIZE
    RESULTS+=("$INTERFACE|$IP|$MTU_SIZE|$?")

done

# Network validation summary
echo
echo "========================================"
echo "       NETWORK VALIDATION SUMMARY"
echo "========================================"

printf "%-15s %-18s %-12s %-10s\n" \
    "INTERFACE" "IP ADDRESS" "MTU SIZE" "STATE"

printf "%-15s %-18s %-12s %-10s\n" \
    "---------" "----------" "--------" "-----"

for RESULT in "${RESULTS[@]}"; do
    IFS='|' read -r IFACE IP MTU STATUS <<< "$RESULT"

    if [ "$STATUS" -eq 0 ]; then
        STATE="PASS"
    else
        STATE="FAIL"
    fi

    printf "%-15s %-18s %-12s %-10s\n" \
        "$IFACE" "$IP" "$MTU" "$STATE"
done


echo "========================================"
