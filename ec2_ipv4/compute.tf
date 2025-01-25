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

data "aws_key_pair" "ssh_key_pair" {
  filter {
    name   = "tag:Name"
    values = [var.tag_name]
  }
}

resource "aws_instance" "linux_server" {
  # Basic Instance Setup
  # count           = var.ec2_instance_count
  ami             = var.ami_id
  instance_type   = var.ec2_instance_type
  key_name        = data.aws_key_pair.ssh_key_pair.key_name
  security_groups = [aws_security_group.allow_ssh.name]

  # Provisioning Setup
  user_data = <<-EOF
        #!/bin/sh
        echo "Welcome to $(hostname)" > /etc/motd.d/${var.tag_name}

        # sshd service config
        echo 'Port ${var.ssh_port}' > /etc/ssh/sshd_config.d/${var.tag_name}.conf
        echo 'PermitRootLogin no' >> /etc/ssh/sshd_config.d/${var.tag_name}.conf
        echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config.d/${var.tag_name}.conf
        systemctl restart sshd
  EOF

  connection {
    type = "ssh"
    user = "ec2-user"
    # private_key = tls_private_key.ssh_key.private_key_pem
    private_key = file("${path.module}/../key_management/${data.aws_key_pair.ssh_key_pair.key_name}.pem")
    host        = aws_instance.linux_server.public_ip
    port        = var.ssh_port
  }

  provisioner "file" {
    source      = "${path.module}/../scripts/amazon_linux_2023_setup.sh"
    destination = "/tmp/setup"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup",
      "DEFAULT_USER=root DEFAULT_USER_PASSWORD=\"${var.default_user_password}\" /tmp/setup"
    ]
  }

  # Resource Tagging
  tags = {
    Name = var.tag_name
  }
}
