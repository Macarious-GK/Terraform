variable "prometheus_deployment" {
  type = object({
    name = string
    namespace = string
    labels = map(string)
    annotations = optional(map(string), {})
    replicas = number
    selector = map(string)
    containers = list(object({
      name = string
      image = string
      resources = optional(object({
        limits = optional(map(string), {})
        requests = optional(map(string), {})
      }), {})
    }))
  })
}

variable "prometheus_service" {
  type = object({
    name = string
    namespace = string
    labels = map(string)
    selector = map(string)
    port = object({
      port        = number
      target_port = number
      protocol    = string
      nodePort    = optional(number, null)
    })
    type = string
  })
  
}