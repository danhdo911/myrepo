def check_snapshot(vm, config):
    snapshot = vm.get("snapshot") or {}

    current_exists = snapshot.get("current_exists", False)

    if current_exists:
        return False, "The VM currently has a snapshot.",

    return True, None
