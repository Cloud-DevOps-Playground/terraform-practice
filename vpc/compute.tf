# data "aws_ami" "latest_ami" {
#   most_recent = true
#   owners      = ["amazon"]
#   filter {
#     name   = "name"
#     values = ["Amazon Linux 2023 AMI"]
#   }
#   filter {
#     name   = "architecture"
#     values = ["x86_64"]
#   }
#   filter {
#     name   = "root-device-type"
#     values = ["ebs"]
#   }
#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }

# # TODO: Terraform doesn't allow this resource
# # if associate_public_ip_address is true
# resource "aws_network_interface" "ipv6_if" {
#   subnet_id           = aws_subnet.ipv6_subnet.id
#   enable_primary_ipv6 = true
#   ipv6_address_count  = 1
#   security_groups     = [aws_security_group.allow_ssh.id]
#   # private_ips = ["172.16.10.100"]

#   # attachment {
#   #   instance     = aws_instance.linux_server.id
#   #   device_index = 0
#   # }

#   tags = {
#     Name = var.tag_name
#   }
# }

resource "aws_instance" "linux_server" {
  count         = var.ec2_instance_count
  ami           = var.ami_id
  instance_type = var.ec2_instance_type

  key_name = aws_key_pair.ssh_key_pair.key_name

  availability_zone      = data.aws_availability_zones.available.names[2]
  enable_primary_ipv6    = true
  ipv6_address_count     = 1
  subnet_id              = aws_subnet.ipv6_subnet.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  # TODO: Understand why these values don't work?
  # associate_public_ip_address = false

  # TODO: Required when aws_network_interface resource is defined
  # network_interface {
  #   network_interface_id = aws_network_interface.ipv6_if.id
  #   device_index         = 0
  # }

  # Use when noy using VPC, conflicts with vpc_security_group_ids
  # NOTE from documentation: If you are creating Instances in a VPC, use vpc_security_group_ids instead.
  # security_groups        = [aws_security_group.allow_ssh.name]

  user_data = <<-EOF
#!/bin/sh
echo 'Port ${var.ssh_port}' > /etc/ssh/sshd_config.d/${var.tag_name}.conf
systemctl restart sshd
  EOF

  tags = {
    Name = var.tag_name
  }

  depends_on = [aws_internet_gateway.ipv6_gw]
}
