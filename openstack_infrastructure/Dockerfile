FROM ubuntu:22.04

WORKDIR /tmp/build

# Disable prompt for apt-get (Prevents apt-get from asking interactive questions)
ENV DEBIAN_FRONTEND=noninteractive

# Install requirement packages with apt
COPY requirements/requirements.apt .
RUN apt-get update && \
    grep -vE '^\s*#|^\s*$' requirements.apt | xargs apt-get install -y && \
    rm -rf /var/lib/apt/lists/*

RUN which python3 && python3 --version && which pip3 && pip3 --version

# Install requirement packages with pip
COPY requirements/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt && \
    rm -rf /root/.cache/pip/

# # Install ansible collections
# COPY requirements/requirements.yml .
# RUN ansible-galaxy collection install -r requirements.yml
    
# # Copy and set entrypoint script
# COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
# RUN chmod +x /usr/local/bin/entrypoint.sh

# ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["sh", "-c"]
