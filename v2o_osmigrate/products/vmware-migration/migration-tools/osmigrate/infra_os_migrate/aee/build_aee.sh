#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

AEE_DIR="${SCRIPT_DIR}"
CERTS_DIR="${WORK_DIR}/certs"

: "${OS_MIGRATE_VERSION:?OS_MIGRATE_VERSION is required}"
CUSTOM_PATCHES="${CUSTOM_PATCHES:-true}"

### Cleanup
cleanup() {
    rm -rf "${AEE_DIR}/certs"
    rm -rf "${AEE_DIR}/context"
    rm -f "${AEE_DIR}/requirements.yml"
}

trap cleanup EXIT

### Copy CA Endpoints
rm -rf "${AEE_DIR}/certs"
cp -a "${CERTS_DIR}" "${AEE_DIR}/certs"

### Generate collection requirements.yml
sed \
    "s/OS_MIGRATE_VERSION/${OS_MIGRATE_VERSION}/g" \
    "${AEE_DIR}/requirements.yml.template" \
    > "${AEE_DIR}/requirements.yml"

### Build AEE
tag_name=vmware-migration-kit

build_args="--progress=plain"
build_args+=" --build-arg CUSTOM_PATCHES=${CUSTOM_PATCHES}"
build_args+=" --build-arg OS_MIGRATE_VERSION=${OS_MIGRATE_VERSION}"

ansible-builder build \
--container-runtime docker \
--verbosity 3 \
--extra-build-cli-args="${build_args}" \
--tag $tag_name

### Verify collections installed
echo ""
echo "Checking installed collection version..."
docker run --rm "${tag_name}" \
    ansible-galaxy collection list