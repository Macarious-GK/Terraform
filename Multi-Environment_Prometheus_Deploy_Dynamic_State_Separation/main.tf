resource "kubernetes_pod" "name" {
    metadata {
        name = "macpod"
    }
    
    spec {
        container {
        image = "nginx:latest"
        name  = "macpod"
    
        port {
            container_port = 80
        }
    }
        toleration {
            key      = "terraform/test"
            operator = "Exists"
            effect   = "NoExecute"
            toleration_seconds = 300
        }
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key = "owner"
                  operator = "In"
                  values = ["mac", "macarious"]
                }
              }
            }
          }
        }
  
}
}