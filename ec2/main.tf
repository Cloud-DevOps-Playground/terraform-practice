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
}

resource "aws_default_vpc" "default" {}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_default_subnet" "default" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

# Dynamically generate a new private key on AWS [Doesn't work as expected]
# resource "tls_private_key" "ssh_key" {
#   algorithm = "ED25519"
#   # algorithm = "RSA"
#   # rsa_bits = 4096
# }

resource "aws_key_pair" "ssh_key_pair" {
  key_name = var.key_name
  # Use the local public key file
  public_key = file(".ssh/${var.key_name}.pem.pub")
}

# Save the dynamically generated key pair pem file
# resource "local_sensitive_file" "pem_file" {
#   filename        = "${path.module}/${var.key_name}.pem"
#   file_permission = "400"
#   # directory_permission = "700"
#   content = tls_private_key.ssh_key.private_key_pem
# }

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
  to_port     = var.ssh_port
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

resource "aws_instance" "linux_server" {
  # availability_zone = data.aws_availability_zones.available.names[0]
  # count           = var.ec2_instance_count
  ami             = var.ami_id
  instance_type   = var.ec2_instance_type
  key_name        = aws_key_pair.ssh_key_pair.key_name
  security_groups = [aws_security_group.allow_ssh.name]

  user_data = <<-EOF
        #!/bin/sh
        echo 'Port ${var.ssh_port}' > /etc/ssh/sshd_config.d/${var.tag_name}.conf
        echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config.d/${var.tag_name}.conf
        echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config.d/${var.tag_name}.conf
        systemctl restart sshd
        echo "HISTCONTROL=ignoreboth" >> ~/.bash_profile
  EOF

  connection {
    type = "ssh"
    user = "ec2-user"
    # private_key = tls_private_key.ssh_key.private_key_pem
    private_key = file(".ssh/${var.key_name}.pem")
    host        = aws_instance.linux_server.public_ip
    port        = var.ssh_port
  }

  provisioner "file" {
    source      = "setup.sh"
    destination = "/tmp/setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup.sh",
      "DEFAULT_USER=root DEFAULT_USER_PASSWORD=\"${var.default_user_password}\" /tmp/setup.sh"
    ]
  }

  tags = {
    Name = var.tag_name
  }
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  # value       = aws_instance.linux_server.*.public_ip
  value = aws_instance.linux_server.public_ip
  # sensitive   = true
}

output "instance_public_dns" {
  description = "Public DNS of the EC2 instance"
  # value       = aws_instance.linux_server.*.public_dns
  value = aws_instance.linux_server.public_dns
  # sensitive   = true
}

# output "selected_ami" {
#   description = "Selected AMI for the EC2 instance"
#   value       = data.aws_ami.latest_ami
# }
