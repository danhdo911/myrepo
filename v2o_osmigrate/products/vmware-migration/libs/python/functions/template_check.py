def check_template(vm, config):
    template = vm.get("template", False)

    if template is True:
        return False, "VM is a template."

    return True, None