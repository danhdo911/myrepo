FROM docker:28-rc-dind

RUN apk add --no-cache \
    bash \
    curl \
    git \
    make \
    jq \
    docker-cli-compose

# Verify versions
RUN docker --version && docker compose version && git --version
