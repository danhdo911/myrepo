FROM docker:28.3.0-cli

RUN apk add --no-cache \
    bash \
    curl \
    git \
    make \
    jq
