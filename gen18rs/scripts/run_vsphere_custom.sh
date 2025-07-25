#!/bin/bash
set -e -o pipefail

echo "**************** Run ansible ****************"
ansible-playbook \
    $ANSIBLE_MAIN_PLAYBOOK \
    -i "$ANSIBLE_INVENTORY" \
    $ANSIBLE_PLAYBOOK_OPTS

