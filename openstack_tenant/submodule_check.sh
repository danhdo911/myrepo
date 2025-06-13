#!/bin/sh

REPO_NAME=${1:-'terraform_vsphere'}
PATH_NAME=${2:-'terraform'}
REPO_URL=${3:-'https://gitlab.iij.com.vn/iijvn-randd/'}


if [ ! -d "$PATH_NAME" ]; then
  echo "🌀 Adding submodule: ${REPO_URL}${REPO_NAME}.git to path $PATH_NAME"
  git submodule add -b main "${REPO_URL}${REPO_NAME}.git" "$PATH_NAME"
  git submodule update --init --recursive
else
  echo "✅ The submodule path '$PATH_NAME' already exists"
  echo "🔄 Updating submodule to latest commit..."
  git submodule update --remote "$PATH_NAME"
fi