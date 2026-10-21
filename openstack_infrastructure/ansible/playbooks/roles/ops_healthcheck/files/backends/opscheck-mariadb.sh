#!/usr/bin/env bash

mariadb_cluster_check() {
  local bad=0

  for node in "${NODES[@]}"; do
    out="$(
      ssh -i "$PRIVATE_KEY_FILE" "$USER@$node" "NODE_LABEL='$node' bash -s" <<'REMOTE'

node="$NODE_LABEL"

docker exec mariadb mysql -uhaproxy -N -B -e \
"SHOW STATUS WHERE Variable_name IN ('wsrep_cluster_status','wsrep_local_state_comment','wsrep_ready','wsrep_connected','wsrep_cluster_size');"

REMOTE
  )"

    if printf '%s\n' "$out" | awk \
        -v node="$node" \
        -v exp_lsc="$EXP_WSREP_LOCAL_STATE_COMMENT" \
        -v exp_size="$EXP_WSREP_CLUSTER_SIZE" \
        -v exp_status="$EXP_WSREP_CLUSTER_STATUS" \
        -v exp_conn="$EXP_WSREP_CONNECTED" \
        -v exp_ready="$EXP_WSREP_READY" '
      BEGIN{
        bad=0
        expect["wsrep_local_state_comment"]=exp_lsc
        expect["wsrep_cluster_size"]=exp_size
        expect["wsrep_cluster_status"]=exp_status
        expect["wsrep_connected"]=exp_conn
        expect["wsrep_ready"]=exp_ready
      }
      {
        name=$1; val=$2
        if (name in expect && val != expect[name]) {
          bad=1
        }
      }
      END{
        if (!bad)
          # printf "✅ %s is good.\n", node
          exit 0
        else
          printf "❌ %s is not good.\n", node
          exit(bad)
      }'; then
      :
    else
      bad=1
    fi
  done

  return "$bad"
}

