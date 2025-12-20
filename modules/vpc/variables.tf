variable "aws_region" {
  description = "Region"
  type        = string
  default     = "us-east-1"
}

variable "ssh_port" {
  description = "Custom SSH port to open for communication over ssh protocol."
  type        = number
  sensitive   = true
  default     = 22
}

variable "tag_name" {
  description = "TAG name for multi instances"
  type        = string
  default     = "terraform-practice"
}
