#!/usr/bin/env bash

set -euo pipefail

set -a
source .env
set +a

echo
echo "========================================"
echo "Deployment Host Verification"
echo "========================================"

FAILED=0

check_cmd() {
    local cmd="$1"

    if command -v "$cmd" >/dev/null 2>&1; then
        echo "  [OK] $cmd"
    else
        echo "  [FAILED] $cmd"
        FAILED=1
    fi
}

check_file() {
    local file="$1"

    if [ -f "$file" ]; then
        echo "  [OK] $file"
    else
        echo "  [FAILED] $file"
        FAILED=1
    fi
}

check_url() {
    local name="$1"
    local url="$2"

    local http_code

    http_code=$(curl -ksS \
        --connect-timeout 5 \
        -o /dev/null \
        -w "%{http_code}" \
        "$url")

    if [ $? -eq 0 ]; then
        echo "  [OK] $name (HTTP ${http_code})"
    else
        echo "  [FAILED] $name (HTTP ${http_code})"
        FAILED=1
    fi
}

echo
echo "Connectivity"

if [ -n "${HARBOR_REGISTRY:-}" ]; then
    check_url "Harbor Registry (${HARBOR_REGISTRY})" \
        "${HARBOR_REGISTRY}"
fi

if [ -n "${VAULT_ADDR:-}" ]; then
    check_url "Vault (${VAULT_ADDR})" \
        "${VAULT_ADDR}/v1/sys/health"
fi

echo
echo "Tools"

check_cmd make
check_cmd git
check_cmd docker
# check_cmd aws
check_cmd vault
# check_cmd oathtool

echo
echo "Configuration Files"

check_file .env
check_file ansible_private_key
check_file "${HOME}/.docker/config.json"
check_file "aws_config"
check_file "aws_credentials"

echo

if [ "$FAILED" -eq 0 ]; then
    echo "Bootstrap verification successful."
else
    echo "Bootstrap verification failed."
    exit 1
fi