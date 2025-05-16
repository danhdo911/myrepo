#!/bin/bash
set -e -o pipefail

echo "**************** Run ansible ****************"
ansible-playbook \
    $ANSIBLE_MAIN_PLAYBOOK \
    -i "$ANSIBLE_ENVIRONMENT_DIR/$ANSIBLE_ENVIRONMENT_DEPLOYMENT/$ANSIBLE_ENVIRONMENT_INVENTORY/$ANSIBLE_INVENTORY_FILE" \
    $ANSIBLE_PLAYBOOK_OPTS

