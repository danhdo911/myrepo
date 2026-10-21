#!/usr/bin/env bash

set -euo pipefail

USER="${USER:-"root"}"
PRIVATE_KEY_FILE="${PRIVATE_KEY_FILE:-"~/.ssh/kolla-ansible"}"

# DOMAIN="dd-iaas.local"
# NODES=(dd-ctl{01..01}.$DOMAIN dd-comp{01..01}.$DOMAIN)
NODES=("$@")

SSH_OPTS=(
  -i "$PRIVATE_KEY_FILE"
  -o BatchMode=yes
  -o StrictHostKeyChecking=no
  -o UserKnownHostsFile=/dev/null
  -o ConnectTimeout=10
)

echo "==================== OpenStack Containers Service ===================="
printf "%-35s %-10s %-10s %-15s %-10s %-10s %-10s\n" \
        "Node" "Total" "Running" "Not-Running" "Healthy" "Unhealthy" "Health-Unknown(-)"
for node in "${NODES[@]}"; do
  out="$(
      ssh "${SSH_OPTS[@]}" "$USER@$node" "NODE_LABEL='$node' bash -s" <<'REMOTE'

node="$NODE_LABEL"

total=0 running=0 not_running=0 healthy=0 unhealthy=0 unknown=0

# Read container names WITHOUT a pipeline (no subshell)
while IFS= read -r c; do
  state=$(docker inspect -f '{{.State.Status}}' "$c")
  health=$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}-{{end}}' "$c")

  (( total++ ))

  if [[ "$state" == running ]]; then
    (( running++ ))
  else
    (( not_running++ ))
    # notrunning_rows+=("$c|$state|$health")
  fi

  case "$health" in
    healthy)
        (( healthy++ ))
        ;;
    unhealthy)
        (( unhealthy++ ))
        # unhealthy_rows+=("$c|$state|$health")
        ;;
    *)
        (( unknown++ ))
        # unknown_rows+=("$c|$state|$health")
        ;;
  esac
done < <(docker ps -a --format '{{.Names}}')

printf '%-35s %-10d %-10d %-15d %-10d %-10d %-10d\n' \
       "$node" "$total" "$running" "$not_running" "$healthy" "$unhealthy" "$unknown"

REMOTE
  )"

  printf '%s\n' "$out"
  sleep 2
done

echo