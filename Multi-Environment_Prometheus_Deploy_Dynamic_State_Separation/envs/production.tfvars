prometheus_service = {
    name = "production-prometheus-service"
    namespace = "test"
    labels = {
        app = "prometheus"
    }   
    selector = {
        app = "prometheus"
    }
    port = {
        port        = 80
        target_port = 9090
        protocol    = "TCP"
        nodePort    = 30300
    }
    type = "NodePort"
}

prometheus_deployment = {
    name = "production-prometheus"
    namespace = "test"
    labels = {
        app = "prometheus"
    }
    annotations = {owner = "devops-team"}
    replicas = 2
    selector = {
        app = "prometheus"
    }
    containers = [
     {
            name  = "prometheus-1"
            image = "prom/prometheus:latest"
            resources = {
            limits = {
                cpu    = "200m"
                memory = "128Mi"
            }
            requests = {
                cpu    = "100m"
                memory = "64Mi"
            }
            }
        }
        ]
}
