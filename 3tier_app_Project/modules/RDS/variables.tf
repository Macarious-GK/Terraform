variable "db_name" {
  description = "The name of the database to create when the DB instance is created"
  type        = string
  default     = "mydb"

}

variable "db_password" {
  description = "RDS root user password"
  sensitive   = true
}

variable "db_username" {
  description = "RDS root username"
  type        = string
  default     = "macadmin"
}

variable "db_port" {
  description = "The port on which the DB accepts connections"
  type        = number
  default     = 3306
}


variable "identifier_name" {
  description = "Unique name for the RDS instance"
  type        = string
}

variable "engine" {
  description = "Database engine (mysql, postgres, etc.)"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
  default     = "14.7"
}

variable "instance_class" {
  description = "RDS instance type"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Initial storage (in GB)"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum storage (autoscaling)"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "Storage type (gp2, gp3, io1)"
  type        = string
  default     = "gp3"
}

variable "subnet_ids" {
  description = "Subnets for RDS subnet group"
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups"
  type        = list(string)
  default     = []
}

variable "multi_az" {
  description = "Enable Multi-AZ for HA"
  type        = bool
  default     = true
}

variable "publicly_accessible" {
  description = "Should the DB be publicly accessible?"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}


variable "parameter_group_family" {
  description = "Parameter group family (e.g., postgres14)"
  type        = string
  default     = "postgres14"
}

variable "parameters" {
  description = "Custom DB parameters"
  type        = map(string)
  default     = {}
}