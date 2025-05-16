#!/bin/bash
set -e -o pipefail


REPO_CODE_URL=$1 # Change to your repo URL
REPO_CODE_DIR=$2 # Change to your target directory

# ROOT_PATH=${ROOT_PATH:-"iijvn"}

# cd /$ROOT_PATH

if [ ! -d "$REPO_CODE_DIR" ]; then
  echo "Directory $REPO_CODE_DIR does not exist. Cloning repository..."
  git clone "$REPO_CODE_URL" "$REPO_CODE_DIR"
else
  echo "Directory $REPO_CODE_DIR already exists. Skipping clone."
fi