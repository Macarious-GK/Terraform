variable "instance_name" {
  description = "The name of the EC2 instance"
  type        = string
  default     = "General_Purpose"
}

variable "instance_owner" {
  description = "The owner of the EC2 instance"
  type        = string
  default     = "Macarious"
}

variable "instance_env" {
  description = "The environment for the EC2 instance"
  type        = string
  default     = "development"
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
  default     = "t3.micro"
}

# variable "associate_vpc_id" {
#   description = "The VPC ID where the EC2 instance will be created"
#   type        = string

# }

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with the EC2 instance"
  type        = bool
  default     = true
}

variable "sg_ids" {
  description = "A list of security group IDs to associate with the EC2 instance"
  type        = list(string)
}

variable "desired_vpc_subnet_id" {
  description = "The ID of the desired VPC subnet for the EC2 instance"
  type        = string
}

variable "user_data" {
  description = "The user data script to run on instance launch"
  type        = string
}

variable "ec2_aws_key_pair" {
  description = "The AWS key pair to use for the EC2 instance"
  type        = any
}