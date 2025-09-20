variable "asg_name" {
  description = "The name of the Auto Scaling group"
  type        = string
  default     = "my-auto-scaling-group"   
  
}

variable "min_size" {
  description = "The minimum size of the Auto Scaling group"
  type        = number
  default     = 1   
  
}
variable "max_size" {
  description = "The maximum size of the Auto Scaling group"
  type        = number
  default     = 3   
  
}
variable "desired_capacity" {
  description = "The desired capacity of the Auto Scaling group"
  type        = number
  default     = 2   
  
}

variable "asg_subnets_ids" {
  description = "A list of subnet IDs to launch resources in"
  type        = list(string)
  default     = []   
  
}

variable "asg_name_tag_value" {
  description = "The value for the Name tag of the Auto Scaling group"
  type        = string
  default     = "my-asg-instance"   
  
}

variable "enable_lb" {
  description = "Whether to enable attaching the ASG to a Load Balancer"
  type        = bool
  default     = false
  
}

variable "lb_target_group_arns" {
  description = "The ARNs of the Load Balancer target groups to attach to the ASG"
  type        = list(string)
  default     = []
}

# Launch Template
variable "launch_template_object" {
  description = "This is object for launch template"
  type = object({
    name_prefix              = string
    ami_id                   = string
    instance_type            = string
    associate_public_ip      = bool
    security_group_ids       = list(string)
    key_name                 = string
    user_data_file_name      = string
    use_user_data            = bool
    user_data_vars           = map(string)
  })
  
}

# variable "launch_template_name_prefix" {
#   description = "The name prefix for the launch template"
#   type        = string
#   default     = "my-launch-template-"   
  
# }

# variable "launch_template_ami_id" {
#   description = "The AMI ID to use for the launch template"
#   type        = string
#   default     = "ami-0360c520857e3138f"   
  
# }

# variable "launch_template_instance_type" {
#   description = "The instance type to use for the launch template"
#   type        = string
#   default     = "t3.micro"   
  
# }

# variable "launch_template_associate_public_ip" {
#   description = "Whether to associate a public IP address with the launch template"
#   type        = bool
#   default     = false
# }

# variable "launch_template_associate_sg_ids" {
#   description = "A list of security group IDs to associate with the launch template"
#   type        = list(string)
#   default     = []    
# }

# variable "launch_template_key_name" {
#   description = "The name of the key pair to use for the launch template"
#   type        = string
#   default     = ""    
  
# }

# variable "launch_template_user_data_file_name" {
#   type        = string
#   description = "Name of user data file (static .sh or templated .tpl)"
# }

# variable "use_template_user_data" {
#   type        = bool
#   description = "Set to true if the user data file is a template (.tpl), false if static (.sh)"
#   default     = false
# }

# variable "template_user_data_vars" {
#   type        = map(any)
#   description = "Variables to inject into templatefile"
#   default     = {}
# }


variable "enable_ami_from_instance" {
  description = "Whether to enable creating an AMI from an existing instance"
  type        = bool
  default     = false
  
}

variable "ami_from_instance_id" {
  description = "The ID of the instance to create an AMI from"
  type        = string
  default     = ""
  
}


# policy
variable "enable_target_tracking_policy" {
  description = "Whether to enable the target tracking scaling policy"
  type        = bool
  default     = true
  
}

variable "target_value_cpu_utilization" {
  description = "The target value for CPU utilization in the scaling policy"
  type        = number
  default     = 20.0
}

variable "target_tracking_metric_type" {
  description = "The predefined metric type for the target tracking scaling policy"
  type        = string
  default     = "ASGAverageCPUUtilization"
  
}
