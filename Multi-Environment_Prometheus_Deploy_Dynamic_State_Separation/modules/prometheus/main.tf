resource "kubernetes_deployment" "example" {
  metadata {
    name        = var.deploy_metadata.name
    namespace   = var.deploy_metadata.namespace
    labels      = var.deploy_metadata.labels
    annotations = var.deploy_metadata.annotations
  }

  spec {
    replicas = var.deploy_spec.replicas
    selector {
      match_labels = var.deploy_spec.selector
    }
    template {
      metadata {
        labels = var.deploy_spec.template.labels
      }

      spec {
        dynamic "container" {
          for_each = var.deploy_spec.template.container
            content{
                image = container.value.image
                name  = container.value.name
                resources {
                  limits = { 
                    memory = container.value.resources.limits["memory"]
                    cpu    = container.value.resources.limits["cpu"]
                  }
                  requests = { 
                    memory = container.value.resources.requests["memory"]
                    cpu    = container.value.resources.requests["cpu"]
                  }
                }

            }
        }
      }
    }
  }
}

resource "kubernetes_service" "service" {
  metadata {
    name      = var.service.name
    namespace = var.service.namespace
    labels    = merge(var.service.labels, { "environment" = var.env })
  }

  spec {
    selector = var.service.selector
    port {
      port        = var.service.port.port
      target_port = var.service.port.target_port
      protocol    = var.service.port.protocol
      node_port   = var.service.port.nodePort
    }
    type = var.service.type
  }
  lifecycle {
    prevent_destroy = false
  }
  provisioner "local-exec" {
    command = "echo 'Deployed Prometheus Service in ${var.env} environment'"
    
  }
  
}