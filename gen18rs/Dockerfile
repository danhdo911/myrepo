FROM ubuntu:24.04

WORKDIR /tmp/build

# Disable prompt for apt-get (Prevents apt-get from asking interactive questions)
ENV DEBIAN_FRONTEND=noninteractive

# Install requirement packages with apt
COPY requirements/requirements.apt .
RUN apt-get update && \
    sed 's/#.*//' requirements.apt | xargs apt-get install -y && \
    apt-get clean all

# Install requirement packages with pip
COPY requirements/requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt --break-system-packages && \
    rm -fr /root/.cache/pip/

# Install ansible collections
COPY requirements/requirements.yml .
RUN ansible-galaxy collection install -r requirements.yml
    
COPY ansible_key /root/.ssh/ansible_key
RUN chmod 600 /root/.ssh/ansible_key

# Copy and set entrypoint script
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /iijvn/vsphere-automation
        
COPY . .

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["ansible-playbook"]
