ARG KOLLA_IMAGE=quay.io/openstack.kolla/cinder-volume:2026.1-ubuntu-noble
FROM ${KOLLA_IMAGE}

USER root

ARG SERVICE_USER=cinder
ARG CEPH_VERSION=20.2.4
ARG UBUNTU_CODENAME=noble

# Add the upstream Ceph repository.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg; \
    mkdir -p /etc/apt/keyrings; \
    curl -fsSL https://download.ceph.com/keys/release.asc \
        -o /etc/apt/keyrings/ceph.asc; \
    echo "deb [signed-by=/etc/apt/keyrings/ceph.asc] https://download.ceph.com/debian-${CEPH_VERSION}/ ${UBUNTU_CODENAME} main" \
        > /etc/apt/sources.list.d/ceph.list; \
    apt-get update; \
    apt-cache policy ceph-common librados2 librbd1; \
    apt-get install -y --no-install-recommends \
        "ceph-common=${CEPH_VERSION}-*" \
        "librados2=${CEPH_VERSION}-*" \
        "librbd1=${CEPH_VERSION}-*"; \
    test "$(ceph --version | grep -c "version ${CEPH_VERSION}")" -eq 1; \
    dpkg-query -W ceph-common librados2 librbd1; \
    rm -rf /var/lib/apt/lists/*

# Restore the original Kolla service user.
USER ${SERVICE_USER}
