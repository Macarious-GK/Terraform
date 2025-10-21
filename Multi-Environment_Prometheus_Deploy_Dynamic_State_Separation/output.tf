output "prometheus_url" {
  value = "https://${data.kubernetes_nodes.master.nodes[0].status[0].addresses[0].address}:${module.prometheus.prometheus_service_node_port}"
}
