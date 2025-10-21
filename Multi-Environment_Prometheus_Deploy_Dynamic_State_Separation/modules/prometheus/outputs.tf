output "prometheus_service_node_port" {
  value = kubernetes_service.service.spec[0].port[0].node_port
}

