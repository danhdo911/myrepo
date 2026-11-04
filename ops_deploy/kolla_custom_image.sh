#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "${SCRIPT_DIR}/.env" ]]; then
    set -a
    source "${SCRIPT_DIR}/.env"
    set +a
fi

# Load inventory
source "${SCRIPT_DIR}/.inventory"

controller_nodes=(
    "$CONTROLLER_01"
    "$CONTROLLER_02"
    "$CONTROLLER_03"
)

compute_nodes=(
    "$COMPUTE_01"
    "$COMPUTE_02"
    "$COMPUTE_03"
)

services=(
    # cinder-volume
    # cinder-backup
    # glance-api
    # nova-libvirt
    nova-compute
)

custom_name="2026.1-ubuntu-noble-ceph20.2.4"

SSH_OPTIONS=(
    -i ${ADMIN_SSH_KEY}
    -o StrictHostKeyChecking=no
    -o IdentitiesOnly=yes
    -o BatchMode=yes
)

for service in "${services[@]}"; do
    image="local/${service}:${custom_name}"
    tar_file="${service}.tar"

    echo "[INFO] Exporting ${image}"

    docker save -o "${tar_file}" "${image}"

    if [[ ! -f "${tar_file}" ]]; then
        echo "[ERROR] Failed to export ${image}"
        exit 1
    fi

    # Determine target nodes
    if [[ "${service}" == "nova-libvirt" || "${service}" == "nova-compute" ]]; then
        target_nodes=("${compute_nodes[@]}")
    else
        target_nodes=("${controller_nodes[@]}")
    fi

    # Distribute image
    for node in "${target_nodes[@]}"; do
        echo "[INFO] Copying ${tar_file} to ${node}"

        scp "${SSH_OPTS[@]}" \
            "${tar_file}" \
            "root@${node}:/tmp/"

        echo "[INFO] Loading image on ${node}"

        ssh "${SSH_OPTS[@]}" "root@${node}" \
            "docker load -i /tmp/${tar_file}"
    done

    echo "[INFO] Completed ${service}"
done

echo "[INFO] All custom Docker images distributed successfully."