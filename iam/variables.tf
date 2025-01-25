variable "aws_region" {
  description = "Region"
  type        = string
  default     = "us-east-1"
}

variable "tag_name" {
  description = "TAG name for multi instances"
  type        = string
  default     = "terraform-practice"
}
