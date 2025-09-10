variable "key_name" {
  description = "Name of the key pair"
  type        = string
  default     = "General_Key_Pair-for-ssh-access-key"
}

variable "key_algorithm" {
  description = "The algorithm to use when generating the key. Valid values are RSA and ECDSA"
  type        = string
  default     = "RSA"

}