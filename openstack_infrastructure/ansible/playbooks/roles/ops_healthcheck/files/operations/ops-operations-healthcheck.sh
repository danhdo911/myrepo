#!/usr/bin/env bash
set -euo pipefail

# =========
# SETTINGS
# =========
# Adjust these to your environment:
# ENVIRONMENT
PS3="Choose environment: "
select OPS_ENV in PRD STG QC DEV LAB; do
  [[ -n "$OPS_ENV" ]] && break
  echo "Invalid choice."
done
echo "Selected: $OPS_ENV"

# APPLICATION CREDENTIAL
APP_CRED_PATH=/etc/kolla/ops-operations-healthcheck-appcred.sh

# NAME (refered to by all components)
BASE_NAME=${BASE_NAME:-"ops-healthcheck"}   # default name
PREFIX_NAME=${1:-}                          # input prefix name when execute script, ex: ./ops-operators-healthcheck.sh test ==> name is ops-healthcheck-test
RESOURCES_NAME="${BASE_NAME}${PREFIX_NAME:+-"$PREFIX_NAME"}"

# Image
ARCH=$(uname -m)
CIRROS_RELEASE=${CIRROS_RELEASE:-0.6.2}
IMAGE_PATH=/opt/cache/files/
IMAGE_URL=https://github.com/cirros-dev/cirros/releases/download/${CIRROS_RELEASE}/
IMAGE=cirros-${CIRROS_RELEASE}-${ARCH}-disk.img
IMAGE_NAME="${BASE_NAME}${PREFIX_NAME:+-"$PREFIX_NAME"}"
IMAGE_TYPE=${IMAGE_TYPE:-"linux"}

# Network
if [[ "$OPS_ENV" == "PRD" ]]; then
  ROUTER_NAME=${ROUTER_name:-"Router-IIJVN-Demo"}   # in PRD env, using the exist router provider
else
  ROUTER_NAME="${BASE_NAME}${PREFIX_NAME:+-"$PREFIX_NAME"}"
fi

EXT_NET=${EXT_NET:-"vlan_provider_internet_access"}         # external network name for FIP
INT_NET="${BASE_NAME}${PREFIX_NAME:+-"$PREFIX_NAME"}"       # tenant local network to external
SUBNET_NAME="${BASE_NAME}${PREFIX_NAME:+-"$PREFIX_NAME"}"   # tenant local subnet to external
NET_CIDR=${NET_CIDR:-'10.0.8.0/24'}
NET_GATEWAY=${NET_GATEWAY:-'10.0.8.254'}
NET_DNS=${NET_DNS:-'8.8.8.8'}

# Server (VM)
SERVER_NAME="${BASE_NAME}${PREFIX_NAME:+-"$PREFIX_NAME"}"
AZ=${AZ:-""}                                                # "nova" or leave empty
FLAVOR=${FLAVOR:-"std_kvm-1c-1g"}                           # flavor for instance
KEY_NAME="${BASE_NAME}${PREFIX_NAME:+-"$PREFIX_NAME"}"      # keypair for access to VM
SECGRP_NAME="${BASE_NAME}${PREFIX_NAME:+-"$PREFIX_NAME"}"   # security group
BOOT_VOL_SIZE=${BOOT_VOL_SIZE:-"5"}                         # GiB
DATA_VOL_SIZE=${DATA_VOL_SIZE:-"10"}                        # GiB
VOL_TYPE=${VOL_TYPE:-""}                                    # optional cinder volume type

# =========
# Check resources info before proceed
echo ""
echo "Resources will be created following as below:"
echo "Server:           $SERVER_NAME ($FLAVOR)"
echo "Keypair:          $KEY_NAME"
echo "Image:            $IMAGE_NAME ($IMAGE)"
echo "Boot volume:      boot-${SERVER_NAME} (${BOOT_VOL_SIZE}G)"
echo "Data volume:      data-${SERVER_NAME} (${DATA_VOL_SIZE}G)"
if [[ "$OPS_ENV" == "PRD" ]]; then
  echo "Router:           $ROUTER_NAME (use exist router)"
else
  echo "Router:           $ROUTER_NAME (create new)"
fi
echo "External network: $EXT_NET"
echo "Internal network: $INT_NET"
echo "Subnet:           $SUBNET_NAME ($NET_CIDR)"
echo "Security group:   $SECGRP_NAME"
echo ""
read -p "Do you want to proceed? (yes/no) " yn

case $yn in
    yes ) echo "Proceeding...";;
    no ) echo "Exiting..."; exit;;
    * ) echo "Invalid response. Exiting..."; exit 1;;
esac

# Source application credentials
if [[ -f "$APP_CRED_PATH" ]]; then
  source "$APP_CRED_PATH"
else
  echo "ERROR: $APP_CRED_PATH not found!"
  exit 1
fi

# Execution
echo ""
echo "==> Check and download glance image with $IMAGE"
if ! [[ -f "$IMAGE_PATH/$IMAGE" ]]; then
    IMAGE_PATH='./'
    if ! [[ -f "$IMAGE_PATH/$IMAGE" ]]; then
        echo "None found, downloading cirros image (version $CIRROS_RELEASE)."
        curl --fail -L -o "$IMAGE_PATH/$IMAGE" "$IMAGE_URL/$IMAGE"
    fi
else
    echo Using cached cirros image from the nodepool node.
fi

echo ""
echo "==> Upload glance image with $IMAGE"
IMAGE_OPTS=(--disk-format qcow2 --container-format bare \
              --property os_type="$IMAGE_TYPE" --file "$IMAGE_PATH/$IMAGE")
IMAGE_ID=$(openstack image create "${IMAGE_OPTS[@]}" "$IMAGE_NAME" -f value -c id)
echo "- Image id: $IMAGE_ID"

echo ""
if [[ "$OPS_ENV" == "PRD" ]]; then
  echo "==> Use exist router provider: $ROUTER_NAME"
  ROUTER_ID=$(openstack router show "$ROUTER_NAME" -f value -c id)
  ROUTER_STATUS=$(openstack router show "$ROUTER_NAME" -f value -c status)
else
  echo "==> Create router with exist external network: $EXT_NET"
  ROUTER_ID=$(openstack router create --external-gateway "$EXT_NET" "$ROUTER_NAME" -f value -c id)
  ROUTER_STATUS=$(openstack router show "$ROUTER_ID" -f value -c status)
fi
echo "- Router id: $ROUTER_ID"
echo "- Router status: $ROUTER_STATUS"

echo ""
echo "==> Create internal and subnet network"
INT_NET_ID=$(openstack network create "$INT_NET" -f value -c id)
SUBNET_OPTS=(--ip-version 4  --network "$INT_NET" --subnet-range "$NET_CIDR" \
              --gateway "$NET_GATEWAY" --dns-nameserver "$NET_DNS")
SUBNET_ID=$(openstack subnet create "${SUBNET_OPTS[@]}" "$SUBNET_NAME" -f value -c id)
echo "- Internal network id: $INT_NET_ID"
echo "- Subnet id: $SUBNET_ID"

echo ""
echo "==> Attach internal subnet to router"
openstack router add subnet "$ROUTER_ID" "$SUBNET_ID"

echo ""
echo "==> Create keypair & security group"
#if ! openstack keypair show "$KEY_NAME" &>/dev/null; then
openstack keypair create "$KEY_NAME" > ~/.ssh/${KEY_NAME}.pem
chmod 600 ~/.ssh/${KEY_NAME}.pem
KEY_ID=$(openstack keypair show "$KEY_NAME" -f value -c id)
echo "- Keypair: ${KEY_ID}"
#fi

#if ! openstack security group show "$SECGRP_NAME" &>/dev/null; then
SECGRP_ID=$(openstack security group create "$SECGRP_NAME" -f value -c id)
echo "- Security group id: $SECGRP_ID"
echo "ICMP rule"
openstack security group rule create --proto icmp "$SECGRP_ID" \
          -f table -c id -c protocol -c remote_ip_prefix
echo "SSH rule"
openstack security group rule create --proto tcp --dst-port 22 "$SECGRP_ID" \
          -f table -c id -c port_range_max -c port_range_min -c protocol -c remote_ip_prefix
#fi

echo ""
echo "==> Create boot-from-volume from image: $IMAGE_NAME (${BOOT_VOL_SIZE}G)"
BOOTVOL_OPTS=(--size "$BOOT_VOL_SIZE" --image "$IMAGE_NAME" \
                --bootable --description "boot vol for $SERVER_NAME")
[[ -n "$VOL_TYPE" ]] && BOOTVOL_OPTS+=(--type "$VOL_TYPE")
BOOT_VOL_ID=$(openstack volume create "${BOOTVOL_OPTS[@]}" "boot-${SERVER_NAME}" -f value -c id)
echo "- Boot volume id: $BOOT_VOL_ID"

echo ""
echo "==> Wait for boot volume available"
until [[ "$(openstack volume show "$BOOT_VOL_ID" -f value -c status)" == "available" ]]; do
  echo "Waiting for server active..."
  sleep 2
done
BOOT_VOL_STATUS=$(openstack volume show "$BOOT_VOL_ID" -f value -c status)
echo "- Boot volume status: $BOOT_VOL_STATUS"

echo ""
echo "==> Boot server from the boot volume"
SERVER_OPTS=(--flavor "$FLAVOR" --volume "$BOOT_VOL_ID" --key-name "$KEY_NAME" \
              --security-group "$SECGRP_NAME" --network "$SUBNET_NAME")
[[ -n "$AZ" ]] && SERVER_OPTS+=(--availability-zone "$AZ")
SERVER_ID=$(openstack server create "${SERVER_OPTS[@]}" "$SERVER_NAME" -f value -c id)
echo "- Server id: $SERVER_ID"

echo ""
echo "==> Wait for server ACTIVE"
#openstack server show "$SERVER_ID" -f table -c id -c name -c status -c addresses
until [[ "$(openstack server show "$SERVER_ID" -f value -c status)" == "ACTIVE" ]]; do
  echo "Waiting for server active..."
  sleep 2
done
openstack server show "$SERVER_ID" -f table -c id -c name -c status -c addresses

echo ""
echo "==> Create extra data volume (${DATA_VOL_SIZE}G)"
DATAVOL_OPTS=(--size "$DATA_VOL_SIZE" --description "data vol for $SERVER_NAME")
[[ -n "$VOL_TYPE" ]] && DATAVOL_OPTS+=(--type "$VOL_TYPE")
DATA_VOL_ID=$(openstack volume create "${DATAVOL_OPTS[@]}" "data-${SERVER_NAME}" -f value -c id)
echo "- Data volume id: $DATA_VOL_ID"

echo ""
echo "==> Wait for data volume available, then attach to server"
until [[ "$(openstack volume show "$DATA_VOL_ID" -f value -c status)" == "available" ]]; do
  echo "Waiting for data volume available..."
  sleep 2
done
openstack server add volume "$SERVER_ID" "$DATA_VOL_ID"
# Optionally wait until 'in-use'
until [[ "$(openstack volume show "$DATA_VOL_ID" -f value -c status)" == "in-use" ]]; do
  sleep 2
done
openstack volume show "$DATA_VOL_ID" -f table -c id -c name -c status -c size -c attachments

echo ""
echo "==> Extend the data volume (+5G) while attached (online extend check)"
NEW_SIZE=$((DATA_VOL_SIZE + 5))
openstack volume set --size "$NEW_SIZE" --os-volume-api-version 3.42 "$DATA_VOL_ID"

echo "  Wait for 'in-use' again after extend completes"
# During extend, status may flip to 'extending' then back to 'in-use'
while true; do
  st=$(openstack volume show "$DATA_VOL_ID" -f value -c status)
  echo "    status: $st"
  [[ "$st" == "in-use" ]] && break
  [[ "$st" == "available" ]] && break
  sleep 3
done
openstack volume show "$DATA_VOL_ID" -f table -c id -c status -c size

echo ""
if [[ "$OPS_ENV" == "DEV" || "$OPS_ENV" == "LAB" ]]; then
  echo "==> Allocate and attach a floating IP from external net: $EXT_NET"
  FIP_ID=$(openstack floating ip create "$EXT_NET" -f value -c id)
  FIP_ADDR=$(openstack floating ip show "$FIP_ID" -f value -c floating_ip_address)
  # Attach to the first port on $INT_NET
  PORT_ID=$(openstack port list --server "$SERVER_ID" --network "$INT_NET" -f value -c ID | head -n1)
  openstack floating ip set --port "$PORT_ID" "$FIP_ID"
  echo "- Floating IP: $FIP_ADDR"
  openstack server show "$SERVER_ID" -f table -c name -c addresses -c status

  echo ""
  echo "==> Quick reachability checks"
  ping -c 3 "$FIP_ADDR" || echo "Ping failed (possible SG/route/image firewall)."
  echo ""
  echo "SSH Info:"
  echo "  ssh -i ~/.ssh/${KEY_NAME}.pem cirros@${FIP_ADDR}"
else
  echo "========================================================================================================="
  echo "Please continue to create and assign an Elasitc IP, Firewall rule from vCD side to check VM connectivity."
  echo ""
fi

echo ""
echo "=========================== SUMMARY ==========================="
resources=('server' 'keypair' 'image' 'volume' 'router' 'subnet' 'network' 'security group')
for r in "${resources[@]}"; do
  echo "=> $r"
  openstack $r list -f table | awk -v pat="$RESOURCES_NAME" '
      { last=$0 }                      # remember last line (bottom border)
      NR<=3 { print; next }            # always print the header (first 3 lines)
      $0 ~ pat { print }               # print only matching rows
      END { print last }               # last line
    '
done

# echo ""
# echo "=== SUMMARY ==="
# echo "Server:         $SERVER_ID ($SERVER_NAME)"
# echo "Keypair:        $KEY_ID"
# echo "Image:          $IMAGE_ID"
# echo "Boot volume:    $BOOT_VOL_ID (${BOOT_VOL_SIZE}G)"
# echo "Data volume:    $DATA_VOL_ID (${NEW_SIZE}G after extend)"
# echo "Floating IP:    $FIP_ID ($FIP_ADDR)"
# echo "Router:         $ROUTER_ID"
# echo "Subnet:         $SUBNET_ID"
# echo "Network:        $INT_NET_ID"
# echo "Security group: $SECGRP_ID"
# echo ""

# echo ""
# echo "=== CLEANUP ==="
# echo "==> Deleting Compute components"
# openstack server delete --force --wait $SERVER_ID
# openstack keypair delete "$KEY_NAME"
# openstack image delete "$IMAGE_ID"
# echo "==> Deleting Network components"
# openstack floating ip delete "$FIP_ID"
# openstack router remove subnet "$ROUTER_ID" "$SUBNET_ID"
# openstack router delete "$ROUTER_ID"
# openstack subnet delete "$SUBNET_ID"
# openstack network delete "$INT_NET_ID"
# openstack security group delete "$SECGRP_ID"
# echo "==> Deleting Storage components"
# openstack volume set --state available "$DATA_VOL_ID"
# openstack volume delete "$DATA_VOL_ID"
# openstack volume set --state available "$BOOT_VOL_ID"
# openstack volume delete "$BOOT_VOL_ID"
# echo "==> Deleting Identity components"
# echo ""

RESOURCES_NAME=ops-healthcheck-before
openstack server list -f value -c name | grep $RESOURCES_NAME | xargs -r openstack server delete --force --wait
sleep 2
openstack keypair list -f value -c name | grep $RESOURCES_NAME | xargs -r openstack keypair delete
sleep 2
openstack image list -f value -c name | grep $RESOURCES_NAME | xargs -r openstack image delete
sleep 2
ROUTER_ID=$(openstack router list -f value -c name | grep $RESOURCES_NAME | xargs -r openstack router show -f value -c id)
SUBNET_ID=$(openstack subnet list -f value -c name | grep $RESOURCES_NAME | xargs -r openstack subnet show -f value -c id)
openstack router remove subnet "$ROUTER_ID" "$SUBNET_ID"
sleep 2
if [[ "$OPS_ENV" == "DEV" || "$OPS_ENV" == "LAB" ]]; then
  openstack router list -f value -c name | grep $RESOURCES_NAME | xargs -r openstack router delete
  sleep 2
fi
openstack subnet list -f value -c name | grep $RESOURCES_NAME | xargs -r openstack subnet delete
sleep 2
openstack network list -f value -c name | grep $RESOURCES_NAME | xargs -r openstack network delete
sleep 2
openstack security group list -f value -c name | grep $RESOURCES_NAME | xargs -r openstack security group delete
sleep 2
openstack volume list -f value -c name | grep $RESOURCES_NAME | xargs -r openstack volume delete

echo "=> Server"
openstack server list -f table | awk 'NR<=3 || /ops-healthcheck/'
echo "=> Keypair"
openstack keypair list -f table | awk 'NR<=3 || /ops-healthcheck/'
echo "=> Image"
openstack image list -f table | awk 'NR<=3 || /ops-healthcheck/'
echo "Volume"
openstack volume list -f table | awk 'NR<=3 || /ops-healthcheck/'
echo "=> Router"
openstack router list -f table | awk 'NR<=3 || /ops-healthcheck/'
echo "=> Subnet"
openstack subnet list -f  table | awk 'NR<=3 || /ops-healthcheck/'
echo "=> Network"
openstack network list -f  table | awk 'NR<=3 || /ops-healthcheck/'
echo "=> Security Group"
openstack security group list -f  table | awk 'NR<=3 || /ops-healthcheck/'


resources=('server' 'keypair' 'image' 'volume' 'router' 'subnet' 'network' 'security group')
for r in "${resources[@]}"; do
  echo "=> $r"
  openstack $r list -f table | awk -v pat="$RESOURCES_NAME" '
      { last=$0 }                      # remember last line (bottom border)
      NR<=3 { print; next }            # always print the header (first 3 lines)
      $0 ~ pat { print }               # print only matching rows
      END { print last }               # last line
    '
done
