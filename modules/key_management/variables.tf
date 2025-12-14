variable "aws_region" {
  description = "Region"
  type        = string
  default     = "us-east-1"
}

variable "key_name" {
  description = "SSH key name"
  type        = string
  default     = "id_ed25519_aws"
}

variable "tag_name" {
  description = "TAG name for multi instances"
  type        = string
  default     = "terraform-practice"
}
