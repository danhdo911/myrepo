#!/bin/bash

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKDIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

ENV_FILE="${ENV_FILE:-}"

if [[ ! -f "$ENV_FILE" ]]; then
    echo "[FAIL] Environment file not found: $ENV_FILE"
    exit 1
fi

echo "[INFO] Loading environment file: $ENV_FILE"

set -a
source "$ENV_FILE"
set +a

FAILED=0

echo "=== VMware Validation ==="

VCENTER_SESSION=$(
    curl -fsS \
        -u "${VMWARE_USER}:${VMWARE_PASSWORD}" \
        -X POST \
        "https://${VMWARE_HOST}/api/session"
)

if [[ -n "$VCENTER_SESSION" ]]; then
    echo "[PASS] vCenter authentication successful."
else
    echo "[FAIL] vCenter authentication failed."
    FAILED=1
fi


echo
echo "=== OpenStack Validation ==="

http_code=$(
curl -fsS \
    -o /tmp/keystone_response.json \
    -w "%{http_code}" \
    -H "Content-Type: application/json" \
    -X POST \
    -d @- \
    "${OS_AUTH_URL%/}/v3/auth/tokens" <<EOF
{
    "auth": {
        "identity": {
            "methods": ["password"],
            "password": {
                "user": {
                    "name": "${OS_USERNAME}",
                    "password": "${OS_PASSWORD}",
                    "domain": {
                        "name": "${OS_USER_DOMAIN_NAME}"
                    }
                }
            }
        },
        "scope": {
            "project": {
                "name": "${OS_PROJECT_NAME}",
                "domain": {
                    "name": "${OS_PROJECT_DOMAIN_NAME}"
                }
            }
        }
    }
}
EOF
)

response="$(cat /tmp/keystone_response.json)"

if [[ "$http_code" != "201" ]]; then
    echo "[FAIL] OpenStack authentication failed (HTTP ${http_code})"
    echo "Response: ${response}"
    FAILED=1
else
    echo "[PASS] OpenStack authentication successful."
fi

echo
if [[ "$FAILED" -eq 0 ]]; then
    echo "[PASS] All connectivity and authentication checks passed."
    exit 0
else
    echo "[FAIL] One or more validation checks failed."
    exit 1
fi
