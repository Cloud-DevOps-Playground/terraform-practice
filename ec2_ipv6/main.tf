terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.84.0"
    }
  }
  required_version = ">= 1.10.0"
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

// Import the key management module which creates the SSH key-pair and writes the PEM file
module "key_management" {
  source     = "../modules/key_management"
  aws_region = var.aws_region
  tag_name   = var.tag_name
  # key_name can be left as default or overridden via root module variables/user.tfvars
  key_name = "${var.tag_name}-key"
}

module "vpc" {
  source     = "../modules/vpc"
  aws_region = var.aws_region
  tag_name   = var.tag_name
  # ssh_port can be left as default or overridden via module inputs
  # ssh_port = 22
}

