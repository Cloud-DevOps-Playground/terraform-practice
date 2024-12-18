terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.81.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region

  # NOTE: Do not enable this tag or it shall tag even the default resources
  # default_tags {
  #   tags = {
  #     Environment = "Dev"
  #     Name        = var.tag_name
  #   }
  # }
}
