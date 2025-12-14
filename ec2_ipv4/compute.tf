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

# data "aws_key_pair" "ssh_key_pair" {
#   filter {
#     name   = "tag:Name"
#     values = [var.tag_name]
#   }
# }
// Use key-pair created by the key_management module

# data "aws_iam_instance_profile" "s3bucket_profile" {
#   name = "s3bucket_iam_instance_profile"
# }

resource "aws_instance" "linux_server" {
  # Ensure the module finished writing the PEM file before creating the instance
  depends_on = [module.key_management]
  # Basic Instance Setup
  count           = var.ec2_instance_count
  ami           = var.ami_id
  instance_type = var.ec2_instance_type
  # key_name        = data.aws_key_pair.ssh_key_pair.key_name
  key_name        = module.key_management.ssh_key_name
  security_groups = [aws_security_group.allow_traffic.name]
  # iam_instance_profile = try(data.aws_iam_instance_profile.s3bucket_profile.name, null)

  # Provisioning Setup
  user_data = <<-EOF
        #!/bin/sh
        echo "Welcome to $(hostname)" > /etc/motd.d/${var.tag_name}

        # sshd service config
        echo 'Port ${var.ssh_port}' > /etc/ssh/sshd_config.d/${var.tag_name}.conf
        echo 'PermitRootLogin no' >> /etc/ssh/sshd_config.d/${var.tag_name}.conf
        echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config.d/${var.tag_name}.conf
        if [[ "debian" == "$(grep -E "^ID_LIKE=" /etc/os-release | cut -d '=' -f 2 | tr -d '"')" ]]; then
          systemctl restart ssh
        elif [[ "fedora" == "$(grep -E "^ID_LIKE=" /etc/os-release | cut -d '=' -f 2 | tr -d '"')" ]]; then
          systemctl restart sshd
        else
          echo "INFO: Unidentified OS family"
        fi
  EOF

  connection {
    type        = "ssh"
    user        = var.default_user
    private_key = module.key_management.ssh_private_key
    host        = self.public_ip
    port        = var.ssh_port
    agent       = false
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
