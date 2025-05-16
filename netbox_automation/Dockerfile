FROM ubuntu:24.04

WORKDIR /netbox

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

# Copy and set entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# #COPY fetch_secrets.sh /usr/local/bin/fetch_secrets.sh
# RUN chmod +x fetch_secrets.sh

COPY . .

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["python3","/netbox/nmap_scan_new_ips.py"]