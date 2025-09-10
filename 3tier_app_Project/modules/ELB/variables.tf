variable "lb_name" {
  description = "The name of the Load Balancer"
  type        = string
  default     = "General_Purpose"
}

variable "lb_owner" {
  description = "The owner of the Load Balancer"
  type        = string
  default     = "Macarious"
}

variable "lb_env" {
  description = "The environment for the Load Balancer"
  type        = string
  default     = "development"
}

variable "vpc_id" {
  description = "The VPC ID where the Loadbalancer will be created"
  type        = string
}

variable "lb_sg_id" {
  description = "This is the SG id for LoadBalancer"
  type        = string

}

variable "TG_name" {
  description = "This is the Target group name"
  type        = string
}

variable "vpc_azs" {
  description = "This is list of the az in the vpc "
  type        = list(string)

}

variable "vpc_public_subnets_ids" {
  description = "this is the list of vpc subnets ids"
  type        = list(string)

}

variable "asg_instance" {
  description = "This is the instance that will be the template for the asg"
  type = string
  
}
