#

## Missing VMware VDDK Library Package

### Issue

Post-deployment ansible task error:

```bash
TASK [conversion : Extract VDDK archive] ***************************************************************************************************************************************************************
Wednesday 19 August 2026  08:06:30 +0000 (0:00:01.116)       0:00:22.402 ******
[ERROR]: Task failed: Could not find or access '/tmp/VMware-vix-disklib-8.0.3-23950268.x86_64.tar.gz' on the Ansible Controller.

Task failed.
Origin: /workspace/playbooks/roles/conversion/tasks/vddk_lib.yml:8:3

6     mode: "0755"
7
8 - name: Extract VDDK archive
    ^ column 3

<<< caused by >>>

Could not find or access '/tmp/VMware-vix-disklib-8.0.3-23950268.x86_64.tar.gz' on the Ansible Controller. If you are using a module and expect the file to exist on the remote, see the remote_src option.

fatal: [<conversion_host>]: FAILED! => {"changed": false, "msg": "Task failed: Could not find or access '/tmp/VMware-vix-disklib-8.0.3-23950268.x86_64.tar.gz' on the Ansible Controller."}
```

### Workaround

Check and upload the VMware VDDK library package to `/tmp/` on the **Migrator host**.

Also, verify the `vddk_archive` variable in the `environments/<TARGET_ENVIRONMENT>/group_vars/conversion_host.yml` playbook to ensure it matches the uploaded VDDK version.

```yaml
vddk_archive: "/tmp/VMware-vix-disklib-8.0.3-23950268.x86_64.tar.gz"
```

Run the configuration task:

```bash
make setup_conversion
```
