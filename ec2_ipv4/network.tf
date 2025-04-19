data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_default_vpc" "default" {}

resource "aws_default_subnet" "default" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Security group to allow ssh traffic."
  tags = {
    Name = var.tag_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "security_group_ingress_rule" {
  security_group_id = aws_security_group.allow_ssh.id
  description       = "Security group ingress rule for ssh connectivity."

  cidr_ipv4   = "${var.my_ip}/32"
  from_port   = var.ssh_port
  to_port     = 5000
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "security_group_egress_rule" {
  security_group_id = aws_security_group.allow_ssh.id
  description       = "Security group egress rule."

  cidr_ipv4 = "0.0.0.0/0"
  # from_port   = 0
  # to_port     = 0
  ip_protocol = "-1"
}
