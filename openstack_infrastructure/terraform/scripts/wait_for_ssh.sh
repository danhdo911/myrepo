#!/bin/bash

# Usage: ./wait_for_ssh.sh <VM_IP>
# Example: ./wait_for_ssh.sh 192.168.1.100

VM_IP="$1"

if [ -z "$VM_IP" ]; then
    echo "Error: Please provide the VM IP address."
    echo "Usage: $0 <VM_IP>"
    exit 1
fi

echo "⏳ Waiting for VM SSH access at $VM_IP..."

until nc -z "$VM_IP" 22; do
    echo "⏳ Still waiting..."
    sleep 1m
done

echo "VM is now reachable via SSH!"
exit 0
