# Integrating OpenStack services after deployment

Change directory to the repository root

```bash
cd /iijvn/higio-platform/openstack
```

Set the environment name for every command.

```bash
export ENV=<Name of the target env directory under environments/>
```

## Skyline RBAC Policy

Enable skyline rbac policy at `./environments/$ENV/ansible/group_vars/kolla_config/services.yml`.

```bash
### Skyline RBAC Policy integration
skyline_policy_enabled: true
skyline_policy_dir: "{{ ansible_env.HOME }}/skyline/policy"
```

Generate configurations.

```bash
make kolla_config ENV=$ENV TAG=globals_config,kolla_skyline_rbac
```

Reconfigure OpenStack services.

```bash
make kolla_shell ENV=$ENV ACTION=reconfigure TAG=nova,cinder,neutron,glance,skyline
```

Create Custom Roles on OpenStack

```bash
make ops_postdeploy ENV=$ENV TAG=custom_roles
```

## HIGIO Portal integration

Enable higio portal and update configurations at `./environments/$ENV/ansible/group_vars/kolla_config/services.yml`.

Sample configuration:

```bash
### HIGIO Portal integration
higio_portal_enabled: true

metadata_nfs_mountpoint:
  - mountpoint: "/metadata"
    path: "/metadata"

skyline_addons_static_url: "https://dev-skyline-console-addons-server.iijvn.local/static"
keystone_trusted_dashboards:
  - "https://iijvnopselb.higio.lab/api/openstack/skyline/api/v1/websso"
keystone_federation_oidc_additional_options:
  OIDCProviderMetadataRefreshInterval: 15
  OIDCDiscoverURL: https://higio-iam.iijvn.local
  OIDCRedirectURLsAllowed: ^https://(iijvnopselb\.higio\.lab|higio-iam\.iijvn\.local|higio-iam-qc\.iijvn\.local)

```

Generate configurations.

```bash
make kolla_config ENV=$ENV TAG=globals_config,kolla_higio_portal
```

Reconfigure OpenStack services.

```bash
make kolla_shell ENV=$ENV ACTION=reconfigure TAG=keystone,skyline
```

## LDAP Horizon integration

Enable ldap horizon and update configurations at `./environments/$ENV/ansible/group_vars/kolla_config/services.yml`.

Sample configuration:

```bash
### LDAP Horizon integration
ldap_horizon_enabled: true
ldap_horizon_server_type: "addc"
ldap_horizon_domain: "dd-iaas.local"
ldap_horizon_url: "ldap://192.168.138.240"
ldap_horizon_suffix: "DC=dd-iaas,DC=local"
ldap_horizon_user_tree_dn: "CN=Users,DC=dd-iaas,DC=local"
ldap_horizon_group_tree_dn: "CN=Users,DC=dd-iaas,DC=local"
ldap_horizon_user_filter: "CN=grp_openstack,CN=Users,DC=dd-iaas,DC=local"
```

Generate configurations.

```bash
make kolla_config ENV=$ENV TAG=globals_config,kolla_ldap_horizon
```

Reconfigure OpenStack services.

```bash
make kolla_shell ENV=$ENV ACTION=reconfigure TAG=keystone,horizon
```

## Monitoring system integration

Enable monitoring system and update configurations at `./environments/$ENV/ansible/group_vars/kolla_config/services.yml`.

Sample configuration:

```bash
### Monitoring system integration
monitoring_enabled: true
monitoring_system_fqdn: "opsoneview.uag.local"
monitoring_system_vip_address: "172.16.81.167"

monitoring_loki_endpoint: "http://{{ monitoring_system_fqdn }}:3100"
```

Generate configurations.

```bash
make kolla_config ENV=$ENV TAG=globals_config,kolla_monitoring
```

> **NOTES**:
>
> In LAB/TEST environments, after run the generate configuartion task, please replace your actual testing monitoring system in these files:
>
> **Prometheus configuration on the infrastructure node:**
>
> - `<kolla_config_prometheus_exporter_dir>/10-node-exporter.yml`:
>   - Replace the node-exporter target:
>
>     `<your_monitoring_system_ip>:9100`
>
> - `<kolla_config_prometheus_exporter_dir>/10-remote-write.yml`:
>   - Replace the remote_write url:
>
>     `http://<your_monitoring_system_fqdn>:8428/api/v1/write`
>
>   - Refer link: [Send data from Prometheus to VictoriaMetrics](https://docs.victoriametrics.com/victoriametrics/integrations/prometheus/).
>
> **Grafana Alloy configuration on all nodes:**
>
> - `/etc/alloy/alloy.config`:
>   - Replace the endpoint url:
>
>     `http://<your_monitoring_system_fqdn>:3100/loki/api/v1/push`
>
>   - Refer link: [Write logs to Loki](https://grafana.com/docs/alloy/latest/tutorials/send-logs-to-loki/#fourth-component-write-logs-to-loki).
>
> **For example in the LAB environment:**
>
> ```bash
> # /etc/kolla/config/prometheus/prometheus.yml.d/10-node-exporter.yml
> scrape_configs:
>   - job_name: node-exporter
>     static_configs:
>       - targets:
>           # Replace '<your_monitoring_system_ip>:9100'.
>           - 172.16.81.167:9100
> ```
>
> ```bash
> # /etc/kolla/config/prometheus/prometheus.yml.d/10-remote-write.yml
> remote_write:
>   # Replace your VictoriaMetrics endpoint: 'http://<your_monitoring_system_fqdn>:8428/api/v1/write'
>   - url: http://opsoneview.uag.local:8428/api/v1/write
>     queue_config:
>       max_samples_per_send: 10000
>       capacity: 20000
>       max_shards: 30
>     tls_config:
>       insecure_skip_verify: true
> ```

Deploy OpenStack Prometheus service.

```bash
make kolla_shell ENV=$ENV ACTION=deploy TAG=prometheus
```

---
