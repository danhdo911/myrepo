resource "nsxt_policy_gateway_prefix_list" "pf" {
  gateway_path = var.gateway_path
  display_name = var.prefix_list_name
  description  = var.description

  dynamic prefix {
    for_each = var.prefixes
    content {
      action  = prefix.value.action
      network = prefix.value.network
      le      = prefix.value.le
      ge      = prefix.value.ge
    }
  }

  dynamic tag {
    for_each = (try(var.scope, "") != "" && try(var.tag, "") != "") ? [1] : []
    content {
      scope = var.scope
      tag   = var.tag
    }
  }
}