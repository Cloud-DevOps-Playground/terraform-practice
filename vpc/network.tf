# Reference for IPV6 VPC configuration:
# https://medium.com/@mattias.holmlund/setting-up-ipv6-on-amazon-with-terraform-e14b3bfef577

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "ipv6_vpc" {
  cidr_block                           = "10.20.30.0/24"
  assign_generated_ipv6_cidr_block     = true
  enable_dns_support                   = true
  enable_dns_hostnames                 = true
  instance_tenancy                     = "default"
  ipv6_cidr_block_network_border_group = var.aws_region

  tags = {
    Name = var.tag_name
  }
}

resource "aws_subnet" "ipv6_subnet" {
  vpc_id = aws_vpc.ipv6_vpc.id

  availability_zone = data.aws_availability_zones.available.names[2]

  # The below fails as 10.20.30.1/32 is not allowed - First 4 and last 1 IPs are reserved by AWS
  cidr_block = cidrsubnet(aws_vpc.ipv6_vpc.cidr_block, 4, 0)

  assign_ipv6_address_on_creation = true
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.ipv6_vpc.ipv6_cidr_block, 8, 1)

  # TODO: Understand why this values doesn't work?
  # ipv6_native                     = true

  map_public_ip_on_launch = false

  tags = {
    Name = var.tag_name
  }
}

resource "aws_internet_gateway" "ipv6_gw" {
  # This parameter takes care of InternetGateway attachment to VPC
  vpc_id = aws_vpc.ipv6_vpc.id

  tags = {
    Name = var.tag_name
  }
}

# This is taken care of in aws_internet_gateway by passing vpc_id
# resource "aws_internet_gateway_attachment" "ipv6_gw_attachment" {
#   internet_gateway_id = aws_internet_gateway.ipv6_gw.id
#   vpc_id              = aws_vpc.ipv6_vpc.id
# }

resource "aws_route_table" "ipv6_route_table" {
  vpc_id = aws_vpc.ipv6_vpc.id

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.ipv6_gw.id
  }

  route {
    ipv6_cidr_block = aws_vpc.ipv6_vpc.ipv6_cidr_block
    gateway_id      = "local"
  }

  tags = {
    Name = var.tag_name
  }
}

resource "aws_route_table_association" "ipv6_rt_association" {
  route_table_id = aws_route_table.ipv6_route_table.id
  subnet_id      = aws_subnet.ipv6_subnet.id
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Security group to allow ssh traffic."
  vpc_id      = aws_vpc.ipv6_vpc.id

  tags = {
    Name = var.tag_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "security_group_ingress_rule" {
  security_group_id = aws_security_group.allow_ssh.id
  description       = "Security group ingress rule for ssh connectivity."

  # cidr_ipv6 = aws_vpc.ipv6_vpc.ipv6_cidr_block
  cidr_ipv6   = "${var.my_ip}/128"
  from_port   = var.ssh_port
  to_port     = var.ssh_port
  ip_protocol = "tcp"

  tags = {
    Name = var.tag_name
    Type = "custom_ssh_port"
  }
}

resource "aws_vpc_security_group_egress_rule" "security_group_egress_rule" {
  security_group_id = aws_security_group.allow_ssh.id
  description       = "Security group egress rule."

  cidr_ipv6   = "::/0"
  ip_protocol = "-1"

  tags = {
    Name = var.tag_name
  }
}
