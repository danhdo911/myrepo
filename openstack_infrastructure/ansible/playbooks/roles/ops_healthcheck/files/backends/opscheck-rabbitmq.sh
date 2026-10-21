#!/usr/bin/env bash

rabbitmq_cluster_check() {

  for node in "${NODES[@]}"; do
    echo "==> On $node"
    out="$(
      ssh -i "$PRIVATE_KEY_FILE" "$USER@$node" "NODE_LABEL='$node' bash -s" <<'REMOTE'

node="$NODE_LABEL"

docker exec rabbitmq rabbitmqctl cluster_status --formatter json

REMOTE
  )"
      printf '%s\n' "$out" |
        jq -r '
        ({listeners: .listeners}),
        ({running_nodes: .running_nodes}),
        ({maintenance_status: .maintenance_status})
        '

      echo ""
  done
}
