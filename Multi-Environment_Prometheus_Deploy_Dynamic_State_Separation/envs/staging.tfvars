
prometheus_deployment = {
    name = "staging-prometheus"
    namespace = "test"
    labels = {
        app = "prometheus"
    }
    annotations = {owner = "devops-team"}
    replicas = 1
    selector = {
        app = "prometheus"
    }
    containers = [
        {
            name  = "nginx-1"
            image = "nginx:latest"
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
        , {
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
