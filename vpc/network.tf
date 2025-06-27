# Reference for IPV6 VPC configuration:
# https://medium.com/@mattias.holmlund/setting-up-ipv6-on-amazon-with-terraform-e14b3bfef577

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "ipv6_vpc" {
  cidr_block                           = "10.0.1.0/24"
  assign_generated_ipv6_cidr_block     = true
  enable_dns_support                   = true
  enable_dns_hostnames                 = true
  instance_tenancy                     = "default"
  ipv6_cidr_block_network_border_group = var.aws_region

  tags = {
    Name = var.tag_name
  }
}

resource "aws_subnet" "ip_subnet" {
  vpc_id = aws_vpc.ipv6_vpc.id

  availability_zone = data.aws_availability_zones.available.names[0]

  cidr_block = cidrsubnet(aws_vpc.ipv6_vpc.cidr_block, 4, 0)

  assign_ipv6_address_on_creation = true
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.ipv6_vpc.ipv6_cidr_block, 8, 1)

  # Cannot be specified when IPv4 is declared
  # ipv6_native = true

  map_public_ip_on_launch = true

  tags = {
    Name = var.tag_name
  }
}

resource "aws_internet_gateway" "ip_gw" {
  # This parameter takes care of InternetGateway attachment to VPC
  vpc_id = aws_vpc.ipv6_vpc.id

  tags = {
    Name = var.tag_name
  }
}

# This is taken care of in aws_internet_gateway by passing vpc_id
# resource "aws_internet_gateway_attachment" "ipv6_gw_attachment" {
#   internet_gateway_id = aws_internet_gateway.ip_gw.id
#   vpc_id              = aws_vpc.ipv6_vpc.id
# }

resource "aws_route_table" "ip_routing_table" {
  vpc_id = aws_vpc.ipv6_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ip_gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.ip_gw.id
  }

  route {
    cidr_block = aws_vpc.ipv6_vpc.cidr_block
    gateway_id = "local"
  }

  route {
    ipv6_cidr_block = aws_vpc.ipv6_vpc.ipv6_cidr_block
    gateway_id      = "local"
  }

  tags = {
    Name = var.tag_name
  }
}

resource "aws_route_table_association" "subnet_routetable_association" {
  route_table_id = aws_route_table.ip_routing_table.id
  subnet_id      = aws_subnet.ip_subnet.id
}

resource "aws_security_group" "allow_traffic" {
  name        = "allow_traffic"
  description = "Security group to allow ssh traffic."
  vpc_id      = aws_vpc.ipv6_vpc.id

  tags = {
    Name = var.tag_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_port" {
  security_group_id = aws_security_group.allow_traffic.id
  description       = "Security group ingress rule for ssh connectivity."

  # cidr_ipv6 = aws_vpc.ipv6_vpc.ipv6_cidr_block
  cidr_ipv6   = "${var.my_ip}/128"
  from_port   = var.ssh_port
  to_port     = var.ssh_port
  ip_protocol = "tcp"

  tags = {
    Name = var.tag_name
    Type = "ssh_port_ingress"
  }
}

# resource "aws_vpc_security_group_ingress_rule" "allow_custom_port" {
#   security_group_id = aws_security_group.allow_traffic.id
#   description       = "Security group ingress rule for custom port connectivity."

#   # cidr_ipv6 = aws_vpc.ipv6_vpc.ipv6_cidr_block
#   cidr_ipv6   = "${var.my_ip}/128"
#   from_port   = 8080
#   to_port     = 8080
#   ip_protocol = "tcp"

#   tags = {
#     Name = var.tag_name
#     Type = "custom_port_ingress"
#   }
# }

resource "aws_vpc_security_group_egress_rule" "security_group_egress_rule_ipv6" {
  security_group_id = aws_security_group.allow_traffic.id
  description       = "Security group egress rule."

  cidr_ipv6   = "::/0"
  ip_protocol = "-1"

  tags = {
    Name = var.tag_name
  }
}

resource "aws_vpc_security_group_egress_rule" "security_group_egress_rule_ipv4" {
  security_group_id = aws_security_group.allow_traffic.id
  description       = "Security group egress rule."

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  tags = {
    Name = var.tag_name
  }
}
