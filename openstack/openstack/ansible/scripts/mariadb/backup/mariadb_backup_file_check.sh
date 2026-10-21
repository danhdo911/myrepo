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

check_backup_file() {
    local host_name="$1"
    local process_name="$2"
    local pid="$3"
    local log_file="$4"
    local backup_path="${5:-/var/lib/docker/volumes/mariadb_backup/_data}"
    local backup_file_pattern="${6:-*.mbs.gz}"
    local backup_file_min_size_mb="${7:-30}"
    local backup_file_age="${8:-0}"

    log_backup "info" "$host_name" "$process_name" "$pid" \
        "Backup file check started. path=${backup_path} pattern=${backup_file_pattern} min_size_mb=${backup_file_min_size_mb} and backup_file_age less than 1 day."

    # Check the backup file exist and is less than 1 day.
    local backup_file
    backup_file="$(find $backup_path -type f -iname "$backup_file_pattern" -mtime $backup_file_age -print -quit)"
    if [[ -z "$backup_file" ]]; then
        log_backup "error" "$host_name" "$process_name" "$pid" \
            "No backup files found in ${backup_path} matching ${backup_file_pattern} with age less than 1 day."
        return 1
    fi

    local backup_file_created=$(stat -c '%Y' $backup_file)
    backup_file_created=$(date -d "@${backup_file_created}" +"%F %T %Z")
    log_backup "info" "$host_name" "$process_name" "$pid" \
        "Found backup file $(basename "$backup_file") is created at ${backup_file_created}"

    # Verify the backup size should be greater than the threshold.
    local backup_file_min_size_bytes=$((backup_file_min_size_mb * 1024 * 1024))
    local backup_file_size_bytes=$(stat -c '%s' $backup_file)
    if [[ $backup_file_size_bytes -lt $backup_file_min_size_bytes ]]; then
        log_backup "warning" "$host_name" "$process_name" "$pid" \
            "Backup file size is too small. file=${backup_file} size_bytes=${backup_file_size_bytes} threshold_bytes=${backup_file_min_size_bytes}"
        return 1
    fi

    log_backup "info" "$host_name" "$process_name" "$pid" \
        "Backup file size is valid. file=${backup_file} size_bytes=${backup_file_size_bytes} threshold_bytes=${backup_file_min_size_bytes}"

    return 0
}

main () {
    # Write log
    local script_name
    script_name="$(basename "${BASH_SOURCE[0]}")"
    script_name="${script_name%.sh}"

    local service="mariadb_backup"
    local log_file="${log_file:-/var/log/kolla/${service}/${script_name}.log}"

    mkdir -p "$(dirname "$log_file")"
    exec >> "$log_file" 2>&1

    # Run MariaDB Backup 
    local host_name="$(hostname)"
    local process_name="$(basename "${BASH_SOURCE[0]}")"
    local pid="$$"

    check_backup_file "$host_name" "$process_name" "$pid" "$log_file"
}

main "$@"