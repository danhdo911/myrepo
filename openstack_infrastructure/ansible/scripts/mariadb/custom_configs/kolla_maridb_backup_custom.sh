#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CUSTOM_CONFIG_DIR="${SCRIPT_DIR}/custom_configs"

KOLLA_ANSIBLE_DIR="${1:-/root/kolla-venv/share/kolla-ansible/ansible}"
MARIADB_ROLE_DIR="${KOLLA_ANSIBLE_DIR}/roles/mariadb"
MARIADB_ROLE_TASKS_DIR="${MARIADB_ROLE_DIR}/tasks"

DIR_LIST=(
    "${CUSTOM_CONFIG_DIR}"
    "${KOLLA_ANSIBLE_DIR}"
    "${MARIADB_ROLE_TASKS_DIR}"
)
for dir in "${DIR_LIST[@]}"; do
    if [[ ! -d "${dir}" ]]; then
        echo "Required directory not found: ${dir}" >&2
        exit 1
    fi
done

FILE_LIST=(
    "${CUSTOM_CONFIG_DIR}/mariadb_backup.yml"
    "${CUSTOM_CONFIG_DIR}/mariadb_backup_check_bkfile.yml"
    "${CUSTOM_CONFIG_DIR}/backup.yml"
)

for file in "${FILE_LIST[@]}"; do
    if [[ ! -f "${file}" ]]; then
        echo "Required custom config file not found: ${file}" >&2
        exit 1
    fi
done

### kolla-venv/share/kolla-ansible/ansible/mariadb_backup.yml
echo ""
echo "---- Replace custom kolla mariadb action into kolla-ansible ----"
BACKUP_ACTION_FILE="mariadb_backup.yml"
SRC_BACKUP_ACTION_FILE="${CUSTOM_CONFIG_DIR}/${BACKUP_ACTION_FILE}"
DEST_BACKUP_ACTION_FILE="${KOLLA_ANSIBLE_DIR}/${BACKUP_ACTION_FILE}"
DEST_BACKUP_ACTION_ORIGIN_FILE="${DEST_BACKUP_ACTION_FILE}.origin"

if [[ ! -f "${DEST_BACKUP_ACTION_ORIGIN_FILE}" ]]; then
    echo "Backing up original ${BACKUP_ACTION_FILE} to ${DEST_BACKUP_ACTION_FILE}.origin"
    if cp "${DEST_BACKUP_ACTION_FILE}" "${DEST_BACKUP_ACTION_FILE}.origin"; then
        echo "Backup successfully: ${DEST_BACKUP_ACTION_FILE}.origin"
    else
        echo "Failed to backup original ${BACKUP_ACTION_FILE}." >&2
        exit 1
    fi
else
    echo "The ${DEST_BACKUP_ACTION_ORIGIN_FILE} found, skipping backup step."
fi

if cp "${SRC_BACKUP_ACTION_FILE}" "${DEST_BACKUP_ACTION_FILE}"; then
    echo "Replaced successfully: ${DEST_BACKUP_ACTION_FILE}"
else
    echo "Failed to replace ${SRC_BACKUP_ACTION_FILE} with custom backup action." >&2
    exit 1
fi

### kolla-venv/share/kolla-ansible/ansible/mariadb_backup_check_bkfile.yml
echo ""
echo "---- Copy custom backup file check task into kolla-ansible ----"
BACKUP_CHECK_FILE="mariadb_backup_check_bkfile.yml"
SRC_BACKUP_CHECK_FILE="${CUSTOM_CONFIG_DIR}/${BACKUP_CHECK_FILE}"
DEST_BACKUP_CHECK_FILE="${KOLLA_ANSIBLE_DIR}/${BACKUP_CHECK_FILE}"

if cp "${SRC_BACKUP_CHECK_FILE}" "${DEST_BACKUP_CHECK_FILE}"; then
    echo "Copied successfully: ${DEST_BACKUP_CHECK_FILE}"
else
    echo "Failed to copy ${SRC_BACKUP_CHECK_FILE} to ${DEST_BACKUP_CHECK_FILE}" >&2
    exit 1
fi

### kolla-venv/share/kolla-ansible/ansible/roles/mariadb/tasks/backup.yml
echo ""
echo "---- Replace kolla mariadb backup task with custom backup task ----"
BACKUP_TASK_FILE="backup.yml"
SRC_BACKUP_TASK_FILE="${CUSTOM_CONFIG_DIR}/${BACKUP_TASK_FILE}"
DEST_BACKUP_TASK_FILE="${MARIADB_ROLE_TASKS_DIR}/${BACKUP_TASK_FILE}"
DEST_BACKUP_TASK_ORIGIN_FILE="${DEST_BACKUP_TASK_FILE}.origin"

if [[ ! -f "${DEST_BACKUP_TASK_FILE}" ]]; then
    echo "Original backup task not found: ${DEST_BACKUP_TASK_FILE}." >&2
    exit 1
fi

if [[ ! -f "${DEST_BACKUP_TASK_ORIGIN_FILE}" ]]; then
    echo "Backing up original ${BACKUP_TASK_FILE} to ${DEST_BACKUP_TASK_ORIGIN_FILE}"
    if cp "${DEST_BACKUP_TASK_FILE}" "${DEST_BACKUP_TASK_ORIGIN_FILE}"; then
        echo "Backup successful: ${DEST_BACKUP_TASK_ORIGIN_FILE}"
    else
        echo "Failed to backup original ${BACKUP_TASK_FILE}" >&2
        exit 1
    fi
else
    echo "The ${DEST_BACKUP_TASK_ORIGIN_FILE} found, skipping backup step."
fi

if cp "${SRC_BACKUP_TASK_FILE}" "${DEST_BACKUP_TASK_FILE}"; then
    echo "Replaced successfully: ${DEST_BACKUP_TASK_FILE}"
else
    echo "Failed to replace ${SRC_BACKUP_TASK_FILE} with custom backup task." >&2
    exit 1
fi

echo ""