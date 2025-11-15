variable "rules" {
    type = list(object({
        description    = string
        priority       = number
        enable_logging = bool
        action         = string
        direction      = string
        match = object({
            src_ip_ranges = list(string)
            dest_ip_ranges = list(string)
            layer4_config = object({
                ip_protocol = string
                ports       = optional(list(string))
            })
        })
    }))
  
}