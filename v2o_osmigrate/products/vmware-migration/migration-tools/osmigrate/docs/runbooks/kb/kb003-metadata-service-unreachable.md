#

## Metadata Service Connection Failure During VM Migration

### Issue

During the VM migration process, Red Hat os-migrate may report the migration task as successful even though the Conversion Host cannot retrieve its OpenStack instance UUID from the metadata service.

The migration task may return:

```bash
TASK [os_migrate.vmware_migration_kit.import_workloads : Migrate Guest from Vmware using nbdkit <vm_name>] ********************************************************************************************************************
task path: /usr/share/ansible/collections/ansible_collections/os_migrate/vmware_migration_kit/roles/import_workloads/tasks/nbdkit.yml:61
Monday 05 October 2026  04:58:30 +0000 (0:00:00.069)       0:00:59.298 ******** 
changed: [<conversion_host>] => {
    "changed": true,
    "id": [
        ""
    ],
    "msg": "VM migrated successfully"
}
```

Because the returned volume ID is empty, the following Get volume metadata info task fails when it attempts to query the Cinder API.

```bash
TASK [os_migrate.vmware_migration_kit.import_workloads : Get volume metadata info] ****************************************************************************************************************************************************
Thursday 24 September 2026  10:37:47 +0000 (0:00:00.064)       0:05:15.062 **** 
[ERROR]: Task failed: Module failed: Failed to get volume metadata:  error: Expected HTTP response code [200] when accessing [GET https://<openstack_cinder_url>/v3/volumes/], but got 404 instead: {"message": "The resource could not be found.<br /><br />\n\n\n", "code": "404 Not Found", "title": "Not Found"}
Origin: /usr/share/ansible/collections/ansible_collections/os_migrate/vmware_migration_kit/roles/import_workloads/tasks/nbdkit.yml:117:3

115     volume_uuid: "{{ migrate_output.id }}"
116
117 - name: Get volume metadata info
      ^ column 3

failed: [<conversion_host>] (item=) => {"ansible_loop_var": "uuid", "changed": false, "converted": false, "msg": "Failed to get volume metadata:  error: Expected HTTP response code [200] when accessing [GET https://<openstack_cinder_url>/v3/volumes/], but got 404 instead: {\"message\": \"The resource could not be found.<br /><br />\\n\\n\\n\", \"code\": \"404 Not Found\", \"title\": \"Not Found\"}", "uuid": ""}
```

The preceding Set fact for disk ID task also shows that the volume UUID is empty:

```bash
TASK [os_migrate.vmware_migration_kit.import_workloads : Set fact for disk ID] ********************************************************************************************************************************************************
task path: /usr/share/ansible/collections/ansible_collections/os_migrate/vmware_migration_kit/roles/import_workloads/tasks/nbdkit.yml:113
Monday 05 October 2026  04:58:34 +0000 (0:00:00.068)       0:01:03.698 ******** 
ok: [<conversion_host>] => {
    "ansible_facts": {
        "volume_uuid": [
            ""
        ]
    },
    "changed": false
}
```

### Investigate

Run the migration with verbose output option `-vvv`, the `Migrate Guest from VMware using nbdkit` task shows the actual failure before the empty volume UUID is returned.

```bash
"2026-10-05T00:58:36-04:00" level=info msg="vCenter connectivity check passed with status code: Normal"
"2026-10-05T00:58:36-04:00" level=info msg="Handling single disk mapping scenario for VM <vm_name>"
"2026-10-05T00:58:36-04:00" level=info msg="Selected volume type <cinder_volume_type> for disk with key 2000 as per volume mapping configured (datastore: <VMWARE_DATASTORE>)"
"2026-10-05T00:58:36-04:00" level=info msg="Migrating disk with key: 2000"
"2026-10-05T00:58:37-04:00" level=info msg="Volume exists, syncing volume.."
"2026-10-05T00:58:37-04:00" level=info msg="Guest Full name: Ubuntu Linux (64-bit)"
"2026-10-05T00:58:37-04:00" level=info msg="Guest ID: ubuntu64Guest"
"2026-10-05T00:58:37-04:00" level=info msg="No Windows OS found in Guest Full name or ID strings..."
"2026-10-05T00:58:37-04:00" level=info msg="Snapshot created: snapshot-2390"
"2026-10-05T00:58:37-04:00" level=info msg="Unexpected status code: 503"
"2026-10-05T00:58:37-04:00" level=info msg="Failed to get instance UUID: <nil>"
"2026-10-05T00:58:37-04:00" level=warning msg="Instance metadata service is not working, please fix it.."
"2026-10-05T00:58:37-04:00" level=warning msg="You can workaround this OpenStack error by providing the instance UUID of the conversion host,"
"2026-10-05T00:58:37-04:00" level=warning msg="directly with the option `instanceuuid`."
"2026-10-05T00:58:37-04:00" level=info msg="Unable to get instance UUID, please provide it manually.."
"2026-10-05T00:58:38-04:00" level=info msg="Snapshot removed: snapshot-2390"
{"msg":"VM migrated successfully","changed":true,"failed":false,"id":[""]}
', b'Shared connection to <conversion_host> closed.
```

### Cause

Red Hat os-migrate requires access to the OpenStack metadata service from the Conversion Host to retrieve the Conversion Host instance UUID.

In this incident, the migration environment uses an HTTP/HTTPS proxy. The metadata and internal OpenStack traffic was not fully excluded from the proxy configuration, causing the Conversion Host to fail when accessing the metadata service.

From the Conversion Host, verify access to the metadata service:

```bash
curl -v \
  http://169.254.169.254/openstack/latest/meta_data.json
```

A successful response should return instance metadata, including the instance UUID.

If the metadata service is unavailable or inaccessible, os-migrate cannot complete the required volume attachment/conversion workflow correctly. This can result in an empty volume UUID and subsequent Cinder API errors.

### Workaround

This workaround allows the migration to proceed without relying on the OpenStack metadata service to retrieve the Conversion Host instance UUID.

Retrieve the Conversion Host UUID from the Horizon/Skyline UI or by running:

```bash
openstack server show <CONVERSION_HOST_NAME> \
  -f value \
  -c id
```

Set the Conversion Host UUID manually in the migration settings file:

```bash
nano ./environments/<TARGET_ENVIRONMENT>/migration_settings.yml
```

Configure:

```bash
import_workloads_instance_uuid: "<CONVERSION_HOST_UUID>"
```

Run the migration again after updating the configuration.

### Permanent fix

Ensure that the metadata endpoint and internal OpenStack infrastructure traffic bypass the HTTP/HTTPS proxy.

The NO_PROXY and no_proxy configuration should include:

- OpenStack metadata endpoint: `169.254.169.254`.
- OpenStack API endpoints.
- Internal OpenStack domains and service endpoints.

Example:

```bash
NO_PROXY="localhost,127.0.0.1,169.254.169.254,<INTERNAL_HOSTS_AND_DOMAINS>"
no_proxy="localhost,127.0.0.1,169.254.169.254,<INTERNAL_HOSTS_AND_DOMAINS>"
```

> [!NOTE]
> When a proxy is used for the migration environment, ensure that all internal communication paths required by OpenStack and the Conversion Host are included in NO_PROXY. The proxy should be used only for external destinations that require it.

### References

- [Unreachable Metadata Service](https://os-migrate.github.io/documentation/#ref_vmw-unreachable-metadata).
- [OpenStack Metadata Service](https://docs.openstack.org/nova/2025.2/admin/metadata-service.html).
