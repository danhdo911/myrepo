from .os_check import get_os_name

def get_virt_v2v_enabled(vm, config):
    os_name = get_os_name(vm, config)

    if os_name is None:
        return None

    requirements = config.get("readiness_requirements", {})
    os_requirements = requirements.get(os_name, {})

    return os_requirements.get("virt_v2v_enabled")

def check_virt_v2v_policy(vm, config):
    enabled = get_virt_v2v_enabled(vm, config)

    if not isinstance(enabled, bool):
        return False, "No virt-v2v policy configured for guest OS."

    return True, None