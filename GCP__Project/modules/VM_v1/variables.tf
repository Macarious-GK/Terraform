variable "vm" {
    type = object({
      name = string
      machine_type = string
      zone = string
      network_interface = object({
          network = optional(string)
          subnetwork = string

        })
    })
  
}