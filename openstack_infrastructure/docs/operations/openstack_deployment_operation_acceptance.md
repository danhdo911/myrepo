# OpenStack Deployment Operation Review and Acceptance

This document is for the technical operation to deploy OpenStack Infrastructure. It records what the automation carries out, what operators should test, the expected results, and the final acceptance criteria.

Run commands from the repository root unless stated otherwise.

## Scope And Sources

| Source | Operational use |
| --- | --- |
| `ansible/` | Main deployment and configuration logic. This is the primary source for this document. |
| `environments/<ENV>/` | Environment-specific Terraform and Ansible variables. |
| `deploy/` | Terraform deployment projects for provisioning infrastructure resources. |
| `terraform/` | Terraform logic module. |
| `docs/new_deployment.md` | Existing deployment command sequence used as the main process reference. |
| `output/` | Generated Terraform output used by Ansible inventory rendering. |
| `Makefile` | Main operator command entrypoint. |
| `bootstrap.sh` | First-time deployment host preparation script. |
| `bootstrap_verify.sh` | Verify deployment host preparation script. |
| `docker-compose.yml` | Container runtime for `terraform` and `ansible_ops` execution. |

## Variable Structure

| Path | Purpose |
| --- | --- |
| `environments/<ENV>/terraform/vms_config.tfvars` | VM declaration for infrastructure provisioning. |
| `environments/<ENV>/ansible/group_vars/all/main.yml` | Common Ansible settings, SSH user/key, and HashiVault lookup variables. |
| `environments/<ENV>/ansible/group_vars/os_baseline/main.yml` | OS baseline inputs: DNS, Proxy, NTP, NFS, Hardening, and SSH authentication. |
| `environments/<ENV>/ansible/group_vars/control/routes.yml` | Extra route definitions for control nodes. |
| `environments/<ENV>/ansible/group_vars/network/routes.yml` | Extra route definitions for network nodes. |
| `environments/<ENV>/ansible/group_vars/kolla_config/main.yml` | OpenStack release, Kolla repository, Kolla directories, workdir layout, and registry defaults. |
| `environments/<ENV>/ansible/group_vars/kolla_config/ops_auth.yml` | OpenStack client authentication artifact paths for Ansible tasks. |
| `environments/<ENV>/ansible/group_vars/kolla_config/services.yml` | OpenStack service configuration and integration toggles. |
| `environments/<ENV>/ansible/group_vars/kolla_config/post_deploy.yml` | Post-deployment resource toggles, currently `qos_volume_enabled`. |
| `environments/<ENV>/ansible/host_vars/` | Host-specific values. Currently used for physical server netplan configuration. |
| `ansible/playbooks/roles/<role>/defaults/main.yml` | Role default values. Operators must check these defaults when a variable is not set in `environments/<ENV>/ansible/`. |

## Review Carried Out Tasks

| Stage | Carried out task | Main command or playbook | Main evidence |
| --- | --- | --- | --- |
| Infrastructure provisioning | Provision OpenStack management, control, network, compute, and infra VMs. | `make terraform_build TF_PROJECT=openstack_aio_provision ENV=<ENV>` then `make terraform_deploy TF_PROJECT=openstack_aio_provision ENV=<ENV>` | Terraform output exists at `output/<ENV>_vms_info.json`. |
| Inventory rendering | Generate Ansible inventory from Terraform VM output. | `make gen_inv ENV=<ENV>` | `environments/<ENV>/ansible/inventory.ini` contains `control`, `network`, `compute`, `infra`, `os_baseline`, and `kolla_config` groups. |
| OS baseline pre-setup | Load Terraform VM data and generate netplan. | `make os_baseline_setup ENV=<ENV> TAG=pre_setup` | `/etc/netplan/<netplan_file_name>` exists on target hosts and networking remains reachable. |
| OS baseline setup | Configure Cloud-init, Hostname, Proxy, DNS, Packages, NTP, Docker, and Kolla SSH key access. | `make os_baseline_setup ENV=<ENV> TAG=setup` | Hosts have expected Hostname, DNS entries, Chrony, Docker, Packages, and Kolla SSH access. |
| OS baseline post-setup | Apply OpenSCAP hardening and SSH administration access. | `make os_baseline_setup ENV=<ENV> TAG=post_setup` | Hardening reports exist under `/opt/os-hardening`; root/admin SSH behavior matches policy. |
| Kolla initialization | Install Kolla-Ansible packages, create venv, install Kolla-Ansible, generate passwords, render Kolla inventory, and log in to registry. | `make kolla_config ENV=<ENV> TAG=kolla_init` | `~/workdir/openstack/os-venv`, `/etc/kolla/passwords.yml`, and `~/workdir/openstack/multinode` exist on the infra node; ~/.docker/config.json exist on the control, network, comput nodes. |
| Kolla globals and core services | Generate `/etc/kolla/globals.yml` and service configs for Nova, Neutron, Cinder, Skyline, Glance/NFS, and Cinder NFS. | `make kolla_config ENV=<ENV> TAG=globals_config,kolla_core_services` | Config files exist under `/etc/kolla` and `/etc/kolla/config`. |
| OpenStack deployment | Run Kolla-Ansible pull, certificates, bootstrap, prechecks, deploy, and post-deploy. | `make kolla_shell ENV=<ENV> ACTION=<action>` | Each Kolla-Ansible action completes with exit code 0. |
| OpenStack auth artifacts | Fetch `clouds.yaml`, fetch CA certificate, and append CA export to `admin-openrc.sh`. | `make ops_postdeploy ENV=<ENV> TAG=ops_auth_fetch,addcerts` | `artifacts/clouds.yaml`, `artifacts/root.crt`, and `OS_CACERT` in `/etc/kolla/admin-openrc.sh`. |
| Flavors | Create OpenStack flavors from `ops_flavors` defaults. | `make ops_postdeploy ENV=<ENV> TAG=flavors` | `openstack flavor list` shows the expected `std_kvm-*` flavors. |
| Nova VNC | Enable Nova `vnc` and configure `novncproxy_base_url` when `nova_vnc_enabled: true`. | `make ops_postdeploy ENV=<ENV> TAG=nova_vnc` | Additional Nova `[vnc]` section exists in `/etc/kolla/config/nova.conf`. |
| QoS volumes | Create volume types, QoS specs, and associations when enabled. | `make ops_postdeploy ENV=<ENV> TAG=qos_volume` | `openstack volume type list` and `openstack volume qos list` show configured QoS resources. |
| Skyline RBAC policy | Create custom OpenStack roles and generate Horizon/Skyline policy configuration. | `make kolla_config ENV=<ENV> TAG=globals_config,kolla_skyline_rbac` | Custom roles exist and policy files are generated for Nova, Neutron, Cinder, Glance, Horizon, and Skyline. And section "2. Skyline Policy Integration" configuration in `/etc/kolla/globals.yml`. |
| HIGIO Portal | Prepare metadata NFS mount for Keystone/Skyline SSO integration. | `make kolla_config ENV=<ENV> TAG=globals_config,kolla_higio_portal` | `/metadata` mount exists on control nodes when enabled. And section "3. HIGIO Portal Integration" configuration in `/etc/kolla/globals.yml`. |
| LDAP Horizon | Create LDAP domain, generate Keystone domain config, and copy Horizon custom settings. | `make kolla_config ENV=<ENV> TAG=globals_config,kolla_ldap_horizon` | Keystone domain exists and `/etc/kolla/config/keystone/domains/keystone.<domain>.conf` is present. And section "4. LDAP Horizon Integration" configuration in `/etc/kolla/globals.yml`. |
| Monitoring | Add DNS for monitoring and generate Prometheus scrape and remote-write config. | `make kolla_config ENV=<ENV> TAG=globals_config,kolla_monitoring` | Prometheus configs exist under `/etc/kolla/config/prometheus/prometheus.yml.d`. And section "5. Monitoring System" configuration in `/etc/kolla/globals.yml`. |
| Health checks | Run OpenStack service and container health checks. | `make ops_healthcheck ENV=<ENV> TAG=healthcheck_services` and `make ops_healthcheck ENV=<ENV> TAG=healthcheck_containers` | Service health check passes and container report shows no failed container state. |

## Test Cases

| ID | Area | Test case |
| --- | --- | --- |
| TC-01 | Terraform output and inventory | Confirm `output/<ENV>_vms_info.json` exists, then run `make gen_inv ENV=<ENV>` and inspect `docker compose -f docker-compose.yml run --rm ansible_ops "ansible-inventory -i environments/<ENV>/ansible/inventory.ini --graph"`. |
| TC-02 | Ansible reachability | Run `docker compose -f docker-compose.yml run --rm ansible_ops "ansible all -i environments/<ENV>/ansible/inventory.ini -m ping"`. |
| TC-03 | OS baseline netplan | After `TAG=pre_setup`, verify IP addresses, default routes, extra routes, and netplan file on all target hosts. Include bond interfaces, vlan interfaces if the physical servers is configured. |
| TC-04 | OS baseline DNS and VIP records | Check `/etc/hosts` and `getent hosts <dns_host>` on OpenStack nodes. |
| TC-05 | OS baseline packages, NTP, timezone, and Docker | Check required packages, `chronyc sources`, `timedatectl`, `docker --version`, and `systemctl is-active docker`. |
| TC-06 | OS baseline SSH and hardening | Check Kolla SSH key access from the infra node to all Kolla nodes. Check OpenSCAP outputs under `/opt/os-hardening` after `TAG=post_setup`. |
| TC-07 | Kolla initialization | After `TAG=kolla_init`, check Kolla venv, Kolla-Ansible version, Kolla passwords, Kolla inventory, registry login, and `ansible all -i ~/workdir/openstack/multinode -m ping` from the infra node. |
| TC-08 | Kolla globals and core config files | After `TAG=globals_config,kolla_core_services`, check `/etc/kolla/globals.yml`, `/etc/kolla/config/nova.conf`, `/etc/kolla/config/neutron/ml2_conf.ini`, `/etc/kolla/config/cinder.conf`, Skyline logos, and `/etc/kolla/config/nfs_shares` when `cinder_nfs_storage_enabled` is enabled. |
| TC-09 | Kolla deployment commands | Run `make kolla_shell ENV=<ENV> ACTION=pull`, `certificates`, `bootstrap-servers`, `prechecks`, `deploy`, and `post-deploy`. |
| TC-10 | Auth artifacts and CA | Run `make ops_postdeploy ENV=<ENV> TAG=ops_auth_fetch,addcerts`, then verify `ansible/playbooks/artifacts/root.crt` and `ansible/playbooks/artifacts/clouds.yaml`. Also check `OS_CACERT` in `/etc/kolla/admin-openrc.sh` on infra node. |
| TC-11 | OpenStack service API health | Run `make ops_healthcheck ENV=<ENV> TAG=healthcheck_services`. The task will check that including `openstack endpoint list`, `openstack compute service list`, `openstack volume service list`, `cinder get-pools`, and `openstack network agent list`. |
| TC-12 | OpenStack container health | Run `make ops_healthcheck ENV=<ENV> TAG=healthcheck_containers`. Review the per-node totals for running, not-running, healthy, unhealthy, and unknown health states. |
| TC-13 | Flavors | Run `make ops_postdeploy ENV=<ENV> TAG=flavors`, then compare `openstack flavor list` with `ansible/playbooks/roles/ops_flavors/defaults/main.yml`. |
| TC-14 | Nova VNC | If `nova_vnc_enabled: true`, run `make ops_postdeploy ENV=<ENV> TAG=nova_vnc`, then reconfigure affected services with `make kolla_shell ENV=<ENV> ACTION=reconfigure TAG=nova`. |
| TC-15 | QoS volumes | If `qos_volume_enabled: true`, run `make ops_postdeploy ENV=<ENV> TAG=qos_volume`, then check `openstack volume type list`, `openstack volume qos list`, and QoS associations. Then `make kolla_shell ENV=<ENV> ACTION=reconfigure TAG=cinder` to applied `default_volume_type`. |
| TC-16 | Skyline RBAC policy | If `skyline_policy_enabled: true`, run `make kolla_config ENV=<ENV> TAG=globals_config,kolla_skyline_rbac`, then reconfigure affected services with `make kolla_shell ENV=<ENV> ACTION=reconfigure TAG=nova,cinder,neutron,glance,skyline`. |
| TC-17 | HIGIO Portal | If `higio_portal_enabled: true`, run `make kolla_config ENV=<ENV> TAG=globals_config,kolla_higio_portal`, then reconfigure with `make kolla_shell ENV=<ENV> ACTION=reconfigure TAG=keystone,skyline`. |
| TC-18 | LDAP Horizon | If `ldap_horizon_enabled: true`, run `make kolla_config ENV=<ENV> TAG=globals_config,kolla_ldap_horizon`, then reconfigure with `make kolla_shell ENV=<ENV> ACTION=reconfigure TAG=keystone,horizon`. |
| TC-19 | Monitoring system | If `monitoring_enabled: true`, run `make kolla_config ENV=<ENV> TAG=globals_config,kolla_monitoring`, then deploy or reconfigure Prometheus with `make kolla_shell ENV=<ENV> ACTION=deploy TAG=prometheus`. |
| TC-20 | End-user smoke test | From a valid OpenStack client session, validate basic read operations: endpoint list, service list, hypervisor list, network agent list, volume service list, image list, and flavor list. If image/network prerequisites exist, boot one test instance and confirm it reaches ACTIVE. |

## Expected Results According To Test Cases

| ID | Expected result |
| --- | --- |
| TC-01 | Terraform output is present and inventory contains expected environment groups and hosts: `control`, `network`, `compute`, and `infra`. |
| TC-02 | All hosts return Ansible `pong`; no unreachable or failed hosts. |
| TC-03 | Netplan files are generated with expected management, tunnel, storage, public, provider, vlan and bond interfaces. Network connectivity remains stable after netplan apply. |
| TC-04 | `/etc/hosts` contains OpenStack management node records and VIP FQDN records. |
| TC-05 | Chrony has valid sources, timezone is `Asia/Ho_Chi_Minh`, Docker is installed and active, and required OS packages are present. |
| TC-06 | Kolla SSH from infra to target nodes works without password prompts. OpenSCAP before/after reports exist and hardening task completed without fatal failure. |
| TC-07 | Kolla venv exists at `/root/workdir/openstack/os-venv`; `kolla-ansible` runs from the venv; `/etc/kolla/passwords.yml` exists with mode `0600`; Kolla multinode inventory exists and passes ping. |
| TC-08 | Kolla config files are present with root ownership and expected permissions. Service-specific configuration reflects variables, including provider VLAN ranges, NFS Cinder backend, and Skyline assets when enabled. |
| TC-09 | All Kolla-Ansible actions finish successfully. `prechecks` reports no blocking issue, and `deploy` plus `post-deploy` complete without failed services. |
| TC-10 | `ansible/playbooks/artifacts/root.crt` and `ansible/playbooks/artifacts/clouds.yaml` exist. Ansible post_deployment tasks can authenticated with `kolla-admin`. `/etc/kolla/admin-openrc.sh` includes `OS_CACERT=/etc/ssl/certs/ca-certificates.crt` on infra node. |
| TC-11 | Endpoint list is returned. Compute and volume services are `enabled` and `up`; Cinder pools are available; network agents are alive and enabled. |
| TC-12 | Container health report shows zero not-running containers and zero unhealthy containers. Any unknown health state must be reviewed and accepted only if the container has no Docker health check by design. |
| TC-13 | Every flavor defined in `ops_flavors/defaults/main.yml` exists in OpenStack with matching vCPU, RAM, disk default, and public visibility. |
| TC-14 | Administrators and tenants can access the graphical console of virtual machines directly from web browser. |
| TC-15 | If `qos_volume_enabled: true`: every QoS volume entry has a volume type, QoS spec, `total_iops_sec` property, and association between the QoS spec and volume type. |
| TC-16 | If `skyline_policy_enabled: true`: custom roles exist, implied roles are configured where expected, and policy files are generated. After reconfigure, Skyline/Horizon access reflects the expected RBAC behavior. |
| TC-17 | If `higio_portal_enabled: true`: metadata NFS mount exists on control nodes. Keystone/Skyline reconfigure succeeds and WebSSO trusted dashboard settings. |
| TC-18 | If `ldap_horizon_enabled: true`: keystone LDAP domain exists, Keystone domain config file is generated for `<domain>`, Horizon/Skyline custom settings are present, and Horizon/Skyline login flow can reach the configured LDAP domain. |
| TC-19 | If `monitoring_enabled: true`: monitoring DNS record is present, Prometheus config fragments are generated, Prometheus deploy/reconfigure succeeds, and configured exporters appear as scrape targets. |
| TC-20 | OpenStack control plane supports basic read operations. Optional instance boot smoke test reaches ACTIVE and does not expose scheduler, network, image, or volume errors. |

## Summary Acceptance Criteria

The deployment is accepted for technical operations when all applicable criteria are true:

- Terraform provisioning completed and `output/<ENV>_vms_info.json` was produced.
- Ansible inventory was generated and all hosts are reachable.
- OS baseline completed for `pre_setup`, `setup`, and `post_setup` with no failed hosts.
- Network, DNS, NTP, Docker, SSH, and hardening checks match environment configuration.
- Kolla initialization completed and generated the venv, passwords, registry login, and Kolla inventory.
- Kolla globals and service configuration files exist under `/etc/kolla` and `/etc/kolla/config`.
- Kolla-Ansible `pull`, `certificates`, `bootstrap-servers`, `prechecks`, `deploy`, and `post-deploy` completed successfully.
- Auth artifacts and CA configuration allow Ansible tasks access with `kolla-admin`.
- OpenStack API endpoints, compute services, volume services, Cinder pools, and network agents are healthy.
- OpenStack containers are running and have no unacceptable unhealthy state.
- Flavor definitions are present and match the template.
- Access the virtual machines console directly from browser.
- QoS volume definitions exist and are correctly associated with the corresponding volume types.
- Enabled integrations for Skyline RBAC, HIGIO Portal, LDAP Horizon, and Monitoring have generated their expected files and passed service reconfigure/deploy.
- Any variable not declared in `environments/<ENV>/ansible/` was checked against the relevant role default in `ansible/playbooks/roles/<role>/defaults/main.yml`.
- No secrets are stored in documentation or committed files; secret values continue to come from Vault or runtime environment variables.

---
This document was generated with AI assistance through vibe coding and validated by [IIJ-DanhDo](https://github.com/IIJ-DanhDo).
