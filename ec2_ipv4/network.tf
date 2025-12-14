data "http" "my_ip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_default_vpc" "default" {}

resource "aws_default_subnet" "default" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_security_group" "allow_traffic" {
  name        = "allow_traffic"
  description = "Security group to allow ssh traffic."
  tags = {
    Name = var.tag_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_traffic.id
  description       = "Security group ingress rule for ssh connectivity."

  cidr_ipv4   = "${chomp(data.http.my_ip.body)}/32"
  from_port   = var.ssh_port
  to_port     = var.ssh_port
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_custom_port" {
  security_group_id = aws_security_group.allow_traffic.id
  description       = "Security group ingress rule for ssh connectivity."

  cidr_ipv4   = "${chomp(data.http.my_ip.body)}/32"
  from_port   = 8080
  to_port     = 8080
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "security_group_egress_rule" {
  security_group_id = aws_security_group.allow_traffic.id
  description       = "Security group egress rule."

  cidr_ipv4 = "0.0.0.0/0"
  # from_port   = 0
  # to_port     = 0
  ip_protocol = "-1"
}

# resource "aws_network_interface" "network_interface_1" {
#   security_groups = [aws_security_group.allow_ssh.id]
#   subnet_id       = aws_default_subnet.default.id

#   attachment {
#     instance     = aws_instance.linux_server.id
#     device_index = 1
#   }
# }

# resource "aws_network_interface" "network_interface_2" {
#   security_groups = [aws_security_group.allow_ssh.id]
#   subnet_id       = aws_default_subnet.default.id

#   attachment {
#     instance     = aws_instance.linux_server.id
#     device_index = 2
#   }
# }