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

# data "aws_iam_instance_profile" "s3bucket_profile" {
#   name = "s3bucket_iam_instance_profile"
# }

resource "aws_instance" "linux_server" {
  # Basic Instance Setup
  # count           = var.ec2_instance_count
  ami             = var.ami_id
  instance_type   = var.ec2_instance_type
  key_name        = data.aws_key_pair.ssh_key_pair.key_name
  security_groups = [aws_security_group.allow_ssh.name]
  # iam_instance_profile = try(data.aws_iam_instance_profile.s3bucket_profile.name, null)

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

  # provisioner "file" {
  #   source      = "${path.module}/../scripts/download_upload.py"
  #   destination = "/tmp/download_upload.py"
  # }

  # provisioner "file" {
  #   source      = "${path.module}/../scripts/requirements.txt"
  #   destination = "/tmp/requirements.txt"
  # }

  # provisioner "file" {
  #   source      = "${path.module}/../scripts/ec2_based_s3_site_setup.sh"
  #   destination = "/tmp/ec2_based_s3_site_setup.sh"
  # }

  # Resource Tagging
  tags = {
    Name = var.tag_name
  }
}
