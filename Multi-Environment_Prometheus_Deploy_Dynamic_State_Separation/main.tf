# resource "kubernetes_namespace" "name" {
#   metadata {
#     name = "default"
#   }
# }

# import {
#   to =  kubernetes_namespace.name
#   id = "default"
# }

locals {
  environments = {
    prod = "production"
    stag = "staging"
  }
}

module "prometheus" {
  source = "./modules/prometheus"
  env = lookup(local.environments, "prod")
  deploy_metadata = {
    name = var.prometheus_deployment.name
    namespace = var.prometheus_deployment.namespace
    labels = var.prometheus_deployment.labels
    annotations = var.prometheus_deployment.annotations
  }

  deploy_spec = {
    replicas = var.prometheus_deployment.replicas
    selector = var.prometheus_deployment.selector
    template = {
      labels = var.prometheus_deployment.selector
      container = var.prometheus_deployment.containers
    }
  }

  service = {
    name = var.prometheus_service.name
    namespace = var.prometheus_service.namespace
    labels = var.prometheus_service.labels
    selector = var.prometheus_service.selector
    port = var.prometheus_service.port
    type = var.prometheus_service.type
  }
}

data "kubernetes_nodes" "master" {
  metadata {
    labels = {
      "owner" = "mac"
    }
  }
}

