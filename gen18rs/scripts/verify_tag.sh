#!/bin/bash

set -e  # Exit on error
set -o pipefail  # Fail on pipeline errors

TAG_TO_DEPLOYMENT=$1

CURRENT_TAG=$(git describe --tags --exact-match 2>/dev/null || echo "none")

if [[ "$TAG_TO_DEPLOYMENT" == "$CURRENT_TAG" ]]; then
    echo "CI_COMMIT_TAG=$TAG_TO_DEPLOYMENT" >> .env
    echo "Tag matches. CI_COMMIT_TAG set in .env"
else
    echo "ERROR: Current commit is not tagged with $TAG_TO_DEPLOYMENT"
    exit 1
fi
