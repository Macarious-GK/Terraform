variable "name" {
  description = "The name of the VPC"
  type        = string
  default     = "General_Purpose"
}

variable "cidr" {
  description = "The IPv4 CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "A list of availability zones in the region"
  type        = list(string)
  default     = ["us-east-1a"]
  validation {
    condition     = (length(var.azs) >= 1 && length(var.azs) <= 3) && alltrue([for az in var.azs : can(regex("^[a-z]{2}-", az))])
    error_message = "You must specify between 1, 2 or 3 availability zones"
  }
}

variable "public_subnets" {
  description = "A list of public subnet CIDR blocks"
  type        = list(string)
  default     = []
  validation {
    condition     = length(var.public_subnets) == 0 || length(var.public_subnets) == length(var.azs)
    error_message = "You can either leave public_subnets empty or specify exactly one subnet CIDR block per availability zone"
  }
}

variable "private_subnets" {
  description = "A list of private subnet CIDR blocks"
  type        = list(string)
  default     = []
  validation {
    condition     = length(var.private_subnets) == 0 || length(var.private_subnets) == length(var.azs) || length(var.private_subnets) == length(var.azs) * 2
    error_message = "You can either leave private_subnets empty or specify exactly one or two subnet CIDR blocks per availability zone"
  }
}

variable "enable_dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "A boolean flag to enable/disable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "nat_gateway" {
  description = "NAT Gateway mode: none | single | perAZ"
  type        = string
  default     = "single"
  validation {
    condition     = contains(["none", "single", "perAZ"], var.nat_gateway)
    error_message = "Invalid NAT gateway type. Valid options are 'none', 'single' or 'perAZ'."
  }
}

variable "tags" {
  description = "A map of tags to assign to the VPC and its resources"
  type        = map(string)
  default = {
    Name        = "default-vpc"
    Owner       = "Macarious"
    Environment = "dev"
  }
}