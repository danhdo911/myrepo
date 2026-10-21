#

## OpenStack Connection Error During Conversion Host Creation

### Issue

During Conversion Host deployment, instance creation may occasionally fail with the following error:

```bash
[INFO] Creating conversion host: dd-vmware-conv-host
Unable to establish connection to https://<openstack_url>:8774/v2.1/servers/243f6e89-2ca9-4f8b-83b0-bfcbfdf88b05: ('Connection aborted.', RemoteDisconnected('Remote end closed connection without response'))

make[1]: *** [Makefile:45: deploy_conversion] Error 1
```

### Workaround

If the Conversion Host instance was created but the deployment did not complete:

Remove the incomplete Conversion Host instance from OpenStack.
Run the deployment again:

```bash
make build_conversion
```

> [!NOTE]
>
> Remove only the incomplete instance. 
>
> Other resources created by the deployment, such as the image, flavor, security group, and key pair, can be reused by the next run.
