#!/usr/bin/env bash

set -euo pipefail

USER="${USER:-"root"}"
PRIVATE_KEY_FILE="${PRIVATE_KEY_FILE:-"/tmp/iij_danhdo"}"

DOMAIN="${DOMAIN:-"higio.lab"}"
NODES=(iijvnopsctl{01..03}.$DOMAIN)

SCRIPT_PATH="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#Call functions health check
#===MariaDB Cluster
source "$SCRIPT_PATH/opscheck-mariadb.sh"
EXP_WSREP_LOCAL_STATE_COMMENT="${EXP_WSREP_LOCAL_STATE_COMMENT:-"Synced"}"
EXP_WSREP_CLUSTER_SIZE="${EXP_WSREP_CLUSTER_SIZE:-"3"}"
EXP_WSREP_CLUSTER_STATUS="${EXP_WSREP_CLUSTER_STATUS:-"Primary"}"
EXP_WSREP_CONNECTED="${EXP_WSREP_CONNECTED:-"ON"}"
EXP_WSREP_READY="${EXP_WSREP_READY:-"ON"}"

#===Rabbitmq Cluster
source "$SCRIPT_PATH/opscheck-rabbitmq.sh"

#Main()
echo "==================== MariaDB Cluster Status ===================="
echo "Checking the status conditions of:"
echo "- WSREP_LOCAL_STATE_COMMENT:    $EXP_WSREP_LOCAL_STATE_COMMENT"
echo "- WSREP_CLUSTER_SIZE:           $EXP_WSREP_CLUSTER_SIZE"
echo "- WSREP_CLUSTER_STATUS:         $EXP_WSREP_CLUSTER_STATUS"
echo "- WSREP_CONNECTED:              $EXP_WSREP_CONNECTED"
echo "- WSREP_READY:                  $EXP_WSREP_READY"
echo ""

if mariadb_cluster_check; then
  echo "✅ Cluster is healthy."
else
  echo "❌ Cluster has issues."
fi

echo ""
echo "==================== Rabbitmq Cluster Status ===================="
rabbitmq_cluster_check

echo ""
