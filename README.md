# To Navigate This Repo
Each folder in this repo represents a cloud resource that can be configured using terraform.

# Sequence To Follow For Resource Setup
## EC2 instance with IPv4 Public IP
1. [AWS Key-Pair Setup](key_management/README.md#AWS_Key-Pair_Management)
2. [EC2 IPv4 Setup](ec2_ipv4/README.md#Deploy_EC2_Instance(s))

## EC2 instance with IPv6 IP
1. [AWS Key-Pair Setup](key_management/README.md#AWS_Key-Pair_Management)
2. [VPC Setup for IPv6 Network](vpc/README.md#Create_VPC)
3. [EC2 IPv6 Setup](ec2_ipv6/README.md#Deploy_EC2_Instance(s))

## S3 bucket creation with associated IAM roles for read-only access via EC2 instance
1. [S3 Bucket Creation](s3/README.md#S3_Bucket)
2. [IAM role for S3 bucket read-only access through EC2 instance](iam/README.md#Setup_IAM_Roles)

# Reference
*  [Terraform Registry for AWS provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
