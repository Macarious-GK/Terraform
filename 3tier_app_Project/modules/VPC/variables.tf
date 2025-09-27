variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = "General_Purpose"
}

variable "vpc_owner" {
  description = "The owner of the VPC"
  type        = string
  default     = "Macarious"
}

variable "vpc_env" {
  description = "The environment for the VPC"
  type        = string
  default     = "development"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

}

variable "public_subnets" {
  description = "A list of public subnet CIDR blocks"
  type        = list(string)
}

variable "private_subnets" {
  description = "A list of private subnet CIDR blocks"
  type        = list(string)

}

variable "number_of_availability_zones" {
  type    = number
  default = 2
}

variable "azs" {
  type = list(string)

  validation {
    condition     = length(var.azs) >= var.number_of_availability_zones
    error_message = "You must provide at least as many AZs as number_of_availability_zones."
  }
}

variable "enable_nat_gateway" {
  description = "Controls if NAT Gateway resources should be created"
  type        = bool
  default     = false
}

variable "enable_dns_support" {
  description = "A boolean flag to enable/disable DNS support in the VPC"
  type        = bool
  default     = true

}

variable "enable_dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC"
  type        = bool
  default     = true

}