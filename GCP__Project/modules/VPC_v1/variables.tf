variable "vpc" {
    type = object({
        name                    = string
        project_id              = string
        auto_create_subnetworks = bool
        subnets = optional(map(object({
            name          = string
            region        = string
            ip_cidr_range = string
        })))
    })
  
}