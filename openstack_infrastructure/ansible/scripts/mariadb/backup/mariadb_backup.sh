#!/bin/bash
set -euo pipefail

log_backup() {
    local level="$1"
    local host_name="$2"
    local process_name="$3"
    local pid="$4"
    shift 4

    local sys_ts="$(date '+%b %d %T')"
    local iso_ts="$(date -u +"%Y-%m-%dT%TZ")"
    local msg="$*"

    printf "%s %s %s[%s]: level=%s ts=%s msg=\"%s\"\n" \
        "$sys_ts" \
        "$host_name" \
        "$process_name" \
        "$pid" \
        "$level" \
        "$iso_ts" \
        "$msg"
}

run_mariadb_backup() {
    local host_name="$1"
    local process_name="$2"
    local pid="$3"
    local log_file="$4"
    local inventory="${5:-/root/workdir/openstack/multinode}"
    local passwords_file="${6:-/etc/kolla/mariadb_backup_password.yml}"
    local vault_id="${7:-mariadbbackup@~/.mariadb_backup_password}"

    echo "=================================================="
    log_backup "info" "$host_name" "$process_name" "$pid" "MariaDB backup started."
    echo ""

    export ANSIBLE_LOG_PATH="/var/log/ansible_mariadb_backup.log"
    EXTRA_OPTS="-u root" kolla-ansible mariadb-backup \
                                    -i "$inventory" \
                                    --passwords "$passwords_file" \
                                    --vault-id "$vault_id"
    local exit_code=$?

    # Using for kolla wrapped. Currently only used in DEV env.
    local kolla_wrapper_path="${8:-/tmp/kolla_wrapper.result}"

    if [[ -s $kolla_wrapper_path ]]; then
        exit_code=$(cat "$kolla_wrapper_path")
    fi

    # Write logs
    if [[ $exit_code -eq 0 ]]; then
        log_backup "info" "$host_name" "$process_name" "$pid" "Kolla-ansible mariadb backup task completed successfully."
        echo "=================================================="
        return 0
    else
        log_backup "error" "$host_name" "$process_name" "$pid" "Kolla-ansible mariadb backup task failed with exit code ${exit_code}. Please check details in ${log_file}."
        echo "=================================================="
        return "$exit_code"
    fi
}

main () {
    # Write log
    local script_name
    script_name="$(basename "${BASH_SOURCE[0]}")"
    script_name="${script_name%.sh}"

    local service="mariadb_backup"
    local log_file="${log_file:-/var/log/${service}/${script_name}.log}"

    mkdir -p "$(dirname "$log_file")"
    exec >> "$log_file" 2>&1

    # Activate Python venv
    local ops_venv="${ops_venv:-/root/workdir/openstack/os-venv}"
    source "${ops_venv}/bin/activate"

    # Run MariaDB Backup 
    local host_name="$(hostname)"
    local process_name="$(basename "${BASH_SOURCE[0]}")"
    local pid="$$"

    run_mariadb_backup "$host_name" "$process_name" "$pid" "$log_file"
}

main "$@"