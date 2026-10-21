#!/bin/bash

set -euo pipefail

ENV_FILE="${ENV_FILE:-}"

if [[ ! -f "$ENV_FILE" ]]; then
    echo "[FAIL] Environment file not found: $ENV_FILE"
    exit 1
fi

echo "[INFO] Loading environment file: $ENV_FILE"

set -a
source "$ENV_FILE"
set +a

# Proxy configuration is optional
if [[ -z "${PROXY_URL:-}" ]]; then
    echo "Proxy is not configured. Skipping Docker proxy configuration."
    exit 0
fi

echo "Configuring Docker daemon proxy..."

sudo mkdir -p /etc/systemd/system/docker.service.d

sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf > /dev/null <<EOF
[Service]
Environment="HTTP_PROXY=${PROXY_URL}"
Environment="HTTPS_PROXY=${PROXY_URL}"
Environment="NO_PROXY=${NO_PROXY}"
EOF

echo "Configuring Docker client proxy..."

mkdir -p "${HOME}/.docker"

cat > "${HOME}/.docker/config.json" <<EOF
{
  "proxies": {
    "default": {
      "httpProxy": "${PROXY_URL}",
      "httpsProxy": "${PROXY_URL}",
      "noProxy": "${NO_PROXY}"
    }
  }
}
EOF

echo "Reloading Docker..."

sudo systemctl daemon-reload
sudo systemctl restart docker

echo "Docker proxy configuration completed."