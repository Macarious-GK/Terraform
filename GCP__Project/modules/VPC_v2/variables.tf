variable "allowed_regions" {
  type    = list(string)
  default = ["us-central1", "us-east1", "us-west1", "europe-west1"]
}
variable "vpc" {
    type = map(object({
        name                    = string
        auto_create_subnetworks = bool
        subnets = optional(map(object({
            name          = string
            region        = string
            ip_cidr_range = string
        })))
    }))
  validation {
    condition = alltrue([for subn, subd in var.vpc : 
        alltrue([for _ ,sd in subd.subnets : contains(var.allowed_regions, sd.region) ])])
    error_message = "the specified region for one or more subnets is not in the allowed regions list."
  }
}
