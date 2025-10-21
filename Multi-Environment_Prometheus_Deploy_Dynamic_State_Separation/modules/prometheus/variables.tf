variable "env" {
  type = string
  
}
variable "deploy_metadata" {
    type = object({
      name = string
      labels = map(string)
      namespace = string
      annotations = optional(map(string), {})
      

    })
}

variable "deploy_spec" {
    type = object({
        replicas = optional(number, 1)
        selector = map(string)
        template = object({
          labels = map(string)
          container = list(object({
            image = string
            name  = string
            resources = optional(object({
              limits = optional(map(string), {})
              requests = optional(map(string), {})
            }), {})
            
        }))
    })
})
}



variable "service" {
  type = object({
    name = string
    labels = map(string)
    namespace = string
    selector = map(string)
    port = object({
      port        = number
      target_port = number
      protocol    = string
      nodePort    = optional(number, null)
    })
    type = string
  })
  validation {
    condition = (var.service.type != "NodePort" || var.service.type == "NodePort" && var.service.port.nodePort != null)
    error_message = "Service type must be 'NodePort'"
  }
}