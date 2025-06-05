#!/bin/bash

set -euo pipefail

DISK="/dev/sda"
PART_NUM=3
PART="${DISK}${PART_NUM}"

echo "Checking if $PART is the last partition on $DISK..."
LAST_PART=$(lsblk -nrpo NAME $DISK | grep -E "${DISK}[0-9]+$" | tail -n1)

if [[ "$LAST_PART" != "$PART" ]]; then
  echo "ERROR: $PART is not the last partition on $DISK."
  exit 1
fi

echo "Getting start sector of $PART..."
START=$(fdisk -l $DISK | awk "\$1 == \"$PART\" { print \$2 }")

echo "Rewriting partition table to grow $PART..."
echo -e "d\n${PART_NUM}\nn\np\n${PART_NUM}\n${START}\n\nw" | fdisk $DISK

echo "Reloading partition table..."
partprobe $DISK
sleep 3

echo "Resizing PV..."
pvresize $PART

echo "Extending logical volume..."
lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv

echo "Resizing filesystem..."
resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv

echo "Done."
