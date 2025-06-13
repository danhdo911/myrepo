output "edge_node_info" {
  value = [
    {
      name = nsxt_edge_transport_node.edge_node.display_name
      id   = nsxt_edge_transport_node.edge_node.id
    }
  ]
}