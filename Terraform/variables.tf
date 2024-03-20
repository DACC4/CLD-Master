variable "cidr_block_a" {
  description = "The CIDR block for the subnet A"
  type        = string
  default     = "10.0.3.0/28" 
}

variable "cidr_block_b" {
  description = "The CIDR block for the subnet B"
  type        = string
  default     = "10.0.3.128/28" 
}

variable "drupal_rds_password" {}