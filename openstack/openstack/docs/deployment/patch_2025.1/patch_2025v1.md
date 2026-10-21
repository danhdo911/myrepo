# Patching for OpenStack 2025.1

Enable custom patches for Kolla/OpenStack services based on project-specific requirements.

Current scope includes:

- Keystone Fernet key synchronization (`fernet-push.sh`)
- Keystone HTTP proxy support when `container_http_proxy` is configured.
- Metadata service authentication and identity integration for the HIGIO portal (Keystone, SSO, Keycloak, etc.)

Set `kolla_patch_enabled` to `true` to apply supported patches after OpenStack deployment.

Available for specific environment, defined at:

`environments/<target_environment_name>/ansible/group_vars/kolla_config/patch.yml`

## Enable custom patches for the target environment

Change directory to the repository root.

```bash
cd /iijvn/higio-platform/openstack
```

Set the environment name for every command.

```bash
export ENV=<Name of the target env directory under environments/>
```

Enable patching for OpenStack at `./environments/$ENV/ansible/group_vars/kolla_config/patch.yml`.

```bash
kolla_patch_enabled: true
```

## Apply keystone_fernet patch

Replace templates:

- `<os-venv>/share/kolla-ansible/ansible/roles/keystone/templates/fernet-push.sh.j2`

```bash
make kolla_patch ENV=$ENV TAG=keystone_fernet
```

Reconfigure OpenStack keystone service.

```bash
make kolla_shell ENV=$ENV ACTION=reconfigure TAG=keystone
```

## Apply keystone_http_proxy patch

Replace files:

- `<os-venv>/share/kolla-ansible/ansible/roles/keystone/defaults/main.yml`
- `<os-venv>/share/kolla-ansible/ansible/roles/keystone/handlers/main.yml`

```bash
make kolla_patch ENV=$ENV TAG=keystone_http_proxy
```

Reconfigure OpenStack keystone service.

```bash
make kolla_shell ENV=$ENV ACTION=reconfigure TAG=keystone
```

## Apply metadata_service patch

Replace templates:

- `<os-venv>/share/kolla-ansible/ansible/roles/keystone/templates/keystone.json.j2`
- `<os-venv>/share/kolla-ansible/ansible/roles/skyline/templates/skyline.yaml.j2`
- `<os-venv>/share/kolla-ansible/ansible/roles/skyline/templates/nginx.conf.j2`

```bash
make kolla_patch ENV=$ENV TAG=metadata_service
```

Reconfigure OpenStack keystone and skyline services.

```bash
make kolla_shell ENV=$ENV ACTION=reconfigure TAG=keystone,skyline
```

## Reference links

- <https://github.com/IIJ-Global-Solutions-Vietnam/higio-platform/issues/4#issuecomment-4796603492>
