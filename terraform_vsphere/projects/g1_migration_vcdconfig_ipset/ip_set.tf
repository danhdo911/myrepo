module "ip_set_111_40_121_160" {
    source             = "../../modules/vcd/ip_set"

    vcd_org            = var.vcd_org
    edge_gateway_id    = data.vcd_nsxt_edgegateway.edgegateway.id

    ip_set_name        = "111_40_121_160"
    ip_set_description = ""
    ip_set_subnets     = ["111.40.121.160/32", "144.217.241.2/32"]
}

