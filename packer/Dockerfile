FROM ubuntu:22.04

WORKDIR /tmp/build

# Disable prompt for apt-get (Prevents apt-get from asking interactive questions)
ENV DEBIAN_FRONTEND=noninteractive

# Install requirement packages with apt
RUN apt-get update \
 && apt-get -y install apt-transport-https ca-certificates curl software-properties-common

RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/hashicorp.gpg \
 && apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
 && apt-get update \
 && apt-get install -y packer vault mkisofs \
 && setcap cap_ipc_lock= /usr/bin/vault

CMD ["sh", "-c"]