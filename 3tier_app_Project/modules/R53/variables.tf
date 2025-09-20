variable "domain_name" {
  description = "The domain name for the Route53 hosted zone"
  type        = string
  
}

variable "www_record_ip" {
  description = "The IP address for the www record"
  type        = string
}
