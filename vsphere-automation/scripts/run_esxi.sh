#!/bin/bash
set -e -o pipefail

echo "**************** Setup ssh-agent ****************"
if [ "$SSH_PRIVATE_KEY" != "" ]; then
  command -v ssh-agent >/dev/null \
  || (apt update -y && apt install openssh-client -y )
  eval $(ssh-agent -s)
  echo "$SSH_PRIVATE_KEY" | tr -d '\r' | ssh-add -
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh
fi

echo "**************** Run ansible ****************"
ansible-playbook \
    $ANSIBLE_MAIN_PLAYBOOK \
    -i "$ANSIBLE_ENVIRONMENT_DIR/$ANSIBLE_ENVIRONMENT_DEPLOYMENT/$ANSIBLE_ENVIRONMENT_INVENTORY/$ANSIBLE_INVENTORY_FILE" \
    $ANSIBLE_PLAYBOOK_OPTS

