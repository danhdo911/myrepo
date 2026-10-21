FROM python:3.11-slim

WORKDIR /tmp/build

# Disable prompt for apt-get (Prevents apt-get from asking interactive questions)
ENV DEBIAN_FRONTEND=noninteractive

# Install requirement packages with apt
COPY requirements/requirements.apt .
RUN apt-get update && \
    grep -vE '^\s*#|^\s*$' requirements.apt | xargs apt-get install -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install requirement packages with pip
COPY requirements/requirements.txt .
RUN pip install --break-system-packages --no-cache-dir -r requirements.txt && \
    rm -rf /root/.cache/pip/

# Install ansible collections
COPY requirements/collections.yml .
RUN ansible-galaxy collection install -r collections.yml


ENTRYPOINT ["/bin/bash", "-c"]
# CMD ["sh", "-c"]
