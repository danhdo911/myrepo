#!/bin/bash
# Source environment variables from .env

if [ -f .env ]; then
    # Export each variable in the .env file
    while IFS='=' read -r key value; do
        # Skip empty lines and comments
        if [ -n "$key" ] && [[ "$key" != \#* ]]; then
            # Handle multiline and special characters
            export "$key=$(echo "$value" | sed 's/^"//;s/"$//;s/\\n/\n/g')"
        fi
    done < .env
fi

# Execute the command passed to the container
exec "$@"
