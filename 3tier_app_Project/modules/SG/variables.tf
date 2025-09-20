variable "sg_name" {
  description = "The name of the security group"
  type        = string
  default     = "General_Purpose"
}

variable "sg_owner" {
  description = "The owner of the security group"
  type        = string
  default     = "Macarious"
}

variable "sg_env" {
  description = "The environment for the security group"
  type        = string
  default     = "development"
}

variable "sg_description" {
  description = "The description of the security group"
  type        = string
  default     = "Allow TLS inbound traffic and all outbound traffic"

}

variable "sg_ingress_rules" {
  description = "A map of ingress rules to be applied to the security group"
  type = map(object({
    description = optional(string)
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = string
  }))
  default = {
    rule1 = {
      description = "Allow HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  }
}

variable "sg_egress_rules" {
  description = "A map of egress rules to be applied to the security group"
  type = map(object({
    description = optional(string)
    from_port   = optional(number)
    to_port     = optional(number)
    protocol    = string
    cidr_blocks = string
  }))
  default = {
    rule1 = {
      description = "Allow all outbound traffic"
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  }
}

variable "vpc_id" {
  description = "The VPC ID where the security group will be created"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC where the security group will be created"
  type        = string
}
