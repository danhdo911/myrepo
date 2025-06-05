#!/bin/bash

LOG_FILE="/opt/vmware/vcloud-director/logs/cell.log"
STOP_FILE="/tmp/stop_tail"

echo "Waiting for cell.log to appear..."
while [ ! -f "$LOG_FILE" ]; do
    sleep 5
done

echo "cell.log found! Streaming logs..."
tail -f "$LOG_FILE" &
TAIL_PID=$!

# Wait for stop signal
while [ ! -f "$STOP_FILE" ]; do
    sleep 5
done

# Kill tail process
echo "Stopping log tailing..."
kill $TAIL_PID
exit 0
