from .os_check import check_os
from .virt_v2v_check import get_virt_v2v_enabled, check_virt_v2v_policy
from .snapshot_check import check_snapshot
from .version_check import check_os_version
from .template_check import check_template


def match_vm(vm, config):
    reasons = []

    for check in (
        check_os,
        check_os_version,
        check_virt_v2v_policy,
        check_snapshot,
        check_template,
    ):
        passed, reason = check(vm, config)

        if not passed:
            reasons.append(reason)

    return len(reasons) == 0, reasons


def filter_vms(vm_data, config):
    ready = {}
    not_ready = {}

    for vm_name, vm in vm_data.items():
        passed, reasons = match_vm(vm, config)

        if passed:
            ready[vm_name] = {
                **vm,
                "virt_v2v_enabled": get_virt_v2v_enabled(vm, config),
            }
        else:
            not_ready[vm_name] = {
                "vm": vm,
                "reasons": reasons,
            }

    return ready, not_ready