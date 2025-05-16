# Ansible for vSphere

## Summary

This project comprises two GitLab repositories:

- Repo [vsphere-automation](https://gitlab.iij.com.vn/iijvn-randd/vsphere-automation) : Contains the main code.
- Repo [vsphere-deployment](https://gitlab.iij.com.vn/iijvn-randd/vsphere_deployment) : Stores environment variables and manages the deployment pipeline.

## Requirements

- **Runner server**:
  - Repo `vsphere-deployment`
  - HashiVault info: `.env`
  - HashiVault token access: `.vault-token`

- **Ansible service**:
  - Packages:
    - Install via apt: `requirements/requirements.apt`
    - Install via pip: `requirements/requirements.txt`
  - Collections: `requirements/requirements.yml`

- **Kickstart server**:
  - DHCP service
  - TFTP service
  - HTTP service
  - Syslinux
  - ESXi source

- **HashiVault**:
  - Secret [iijvn-ansiblevsphere](https://vault.iij.com.vn/ui/vault/secrets/iijvn-ansiblevsphere/kv/list)
