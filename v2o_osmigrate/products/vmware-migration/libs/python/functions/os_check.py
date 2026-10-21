def normalize_os_name(os_name, config):
    raw_os_name = str(os_name or "").strip().lower()
    requirements = config.get("readiness_requirements", {})

    for canonical_name, requirement in requirements.items():
        for alias in requirement.get("aliases", []):
            if alias.lower() in raw_os_name:
                return canonical_name

    return None

def get_os_name(vm, config):
    os_name = normalize_os_name(vm.get("os_name"), config)

    if os_name:
        return os_name

    # Fallback to VMware guestFullName
    return normalize_os_name(vm.get("guest_os_fullname"), config)


def check_os(vm, config):
    os_name = get_os_name(vm, config)

    if os_name is None:
        return (
            False,
            f"Unsupported operating system: "
            f"{vm.get('os_name')} ({vm.get('guest_os_fullname')})",
        )

    return True, None
