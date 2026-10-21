#!/usr/bin/env bash

set -e

echo "[$(date)] Updating credentials..."

# Variables
MAX_RETRIES=3
RETRY_INTERVAL=5  # seconds
RETRY=0

ROOT_PROFILE="default"
MFA_PROFILE="default_mfa"

# Compute a single-use MFA code
MFA_SERIAL="$(aws configure get mfa_serial --profile $ROOT_PROFILE)"
MFA_SEED="$(aws configure get mfa_seed --profile $ROOT_PROFILE)"

while [ $RETRY -lt $MAX_RETRIES ]; do
    MFA_TOKEN="$(oathtool -b --totp "$MFA_SEED")"
    echo "[Attempt $((RETRY+1))] Generated MFA Token: $MFA_TOKEN"

    CREDENTIALS="$(aws sts get-session-token \
                    --profile $ROOT_PROFILE \
                    --serial-number $MFA_SERIAL \
                    --token-code $MFA_TOKEN \
                    --duration-seconds 3600 2>&1)"
    if echo "$CREDENTIALS" | grep -q '"Credentials"'; then
            echo "✅ Session token retrieved successfully."
            break
    else
        echo "❌ Failed to retrieve session token: $CREDENTIALS"
        RETRY=$((RETRY + 1))
        sleep "$RETRY_INTERVAL"
    fi
done

if [ $RETRY -eq $MAX_RETRIES ]; then
    echo "❗ Failed to get session token after $MAX_RETRIES attempts. Exiting."
    exit 1
fi

# Parse output from previous command
SESSION_TOKEN="$(echo "${CREDENTIALS}" | jq -r '.Credentials.SessionToken')"
ACCESS_KEY_ID="$(echo "${CREDENTIALS}" | jq -r '.Credentials.AccessKeyId')"
SECRET_ACCESS_KEY="$(echo "${CREDENTIALS}" | jq -r '.Credentials.SecretAccessKey')"

# Set credentials in AWS credentials file
aws configure set profile.${MFA_PROFILE}.aws_access_key_id "$ACCESS_KEY_ID"
aws configure set profile.${MFA_PROFILE}.aws_secret_access_key "$SECRET_ACCESS_KEY"
aws configure set profile.${MFA_PROFILE}.aws_session_token "$SESSION_TOKEN"

echo "[$(date)] Credentials updated."