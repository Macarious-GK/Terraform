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

variable "lb_type" {
  description = "The type of the Load Balancer"
  type        = string
  default     = "application"
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

variable "vpc_subnets_ids" {
  description = "this is the list of vpc subnets ids"
  type        = list(string)

}

# Listener variables
variable "lb_listener_port" {
  description = "The port on which the load balancer is listening"
  type        = number
  default     = 80
}
variable "lb_listener_protocol" {
  description = "The protocol for the listener"
  type        = string
  default     = "HTTP"
}

variable "enable_attachment" {
  description = "Whether to enable attaching targets to the Load Balancer target group"
  type        = bool
  default     = false
  
}

variable "lb_tg_target_id" {
  description = "The ID of the target to attach to the target group (e.g., instance ID)"
  type        = string
  default = null
}