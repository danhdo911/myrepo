#!/bin/bash
set -euo pipefail

# Configurations
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_NAME="${SCRIPT_NAME%.sh}"
SERVICE="mariadb_backup"

LOG_FILE="${LOG_FILE:-/var/log/kolla/$SERVICE/$SCRIPT_NAME.log}"
BACKUP_PATH="${BACKUP_PATH:-/var/lib/docker/volumes/mariadb_backup/_data}"
NFS_PATH="${NFS_PATH:-/glance/backup_ops_db}"

mkdir -p "$(dirname "$LOG_FILE")"
exec >> "$LOG_FILE" 2>&1

echo "====== $(date) ======"

# Move all content of mariadb backup
if [ ! -d "$NFS_PATH" ]; then
    mkdir -p "$NFS_PATH"
fi

if [ $(find "$BACKUP_PATH" -mindepth 1 | wc -l) -eq 0 ]; then
    echo "Folder is empty, skipping backup move."
else
    echo "====== Move MariaDB Backup to NFS ======"
    mv -v $BACKUP_PATH/* $NFS_PATH/
fi

# Delete file older than 7 days
echo "====== Delete backup files older than 7 days ======"
find "$NFS_PATH/" -type f -mtime +7 -exec rm -v {} \;
