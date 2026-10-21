import re
from .os_check import normalize_os_name
from .os_check import get_os_name

def parse_version(version):
    numbers = re.findall(r"\d+", str(version or ""))

    if not numbers:
        return ()

    return tuple(int(number) for number in numbers)

def parse_windows_version(guest_os_fullname):
    match = re.search(
        r"Windows Server\s+(\d{4})",
        str(guest_os_fullname or ""),
        re.IGNORECASE,
    )

    if not match:
        return None

    return match.group(1)

def check_os_version(vm, config):
    os_name = get_os_name(vm, config)

    if os_name is None:
        return False, "Unsupported operating system."

    # Get OS-specific readiness requirements
    requirements = config.get("readiness_requirements", {})
    os_requirements = requirements.get(os_name, {})
    minimum_version = os_requirements.get("minimum_version")

    if minimum_version is None:
        return False, f"No minimum OS version configured for {os_name}."

    # Determine OS version
    if os_name == "windows_server":
        os_version = parse_windows_version(vm.get("guest_os_fullname"))
    else:
        os_version = vm.get("os_version")

    current = parse_version(os_version)
    if not current:
        return False, f"Unable to parse OS version: {os_version}."

    minimum = parse_version(minimum_version)
    if current < minimum:
        return (
            False,
            f"{os_name} {os_version} is below the minimum supported version ({minimum_version}).",
        )

    return True, None
