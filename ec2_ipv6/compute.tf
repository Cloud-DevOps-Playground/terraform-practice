# data "aws_ami" "latest_ami" {
#   most_recent = true
#   owners      = ["amazon"]
#   filter {
#     name   = "name"
#     values = ["Amazon Linux 2023 AMI"]
#   }
#     filter {
#       name   = "architecture"
#       values = ["x86_64"]
#     }
#   filter {
#     name   = "root-device-type"
#     values = ["ebs"]
#   }
#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }

# resource "random_integer" "az" {
#   min = 0
#   max = 2
# }

data "aws_availability_zones" "available" {
  state = "available"
}

# Using vpc module outputs for network resources: module.vpc.subnet_ids, module.vpc.security_group_id, module.vpc.ssh_port

# # Not used. Hence commented.
# data "aws_vpc_security_group_rule" "custom_port_ingress" {
#   filter {
#     name   = "tag:Name"
#     values = ["${var.tag_name}"]
#   }

#   filter {
#     name   = "tag:Type"
#     values = ["custom_port_ingress"]
#   }
# }

# Uncomment, if attaching to S3 bucket (line 121)
# data "aws_iam_instance_profile" "s3bucket_profile" {
#   name = "s3bucket_iam_instance_profile"
# }

# # Note: Terraform doesn't allow this resource
# # if associate_public_ip_address is true
# resource "aws_network_interface" "ipv6_if" {
#   for_each               = toset(data.aws_subnets.ip_subnet.ids)
#   subnet_id              = each.value
#   # subnet_id           = data.aws_subnet.ip_subnet.id
#   enable_primary_ipv6 = true
#   ipv6_address_count  = 1
#   security_groups     = [data.aws_security_groups.allow_traffic.id]
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
  # Instance Basic Setup
  ami = var.ami_id
  # availability_zone = data.aws_availability_zones.available.names[random_integer.az.result]
  availability_zone = data.aws_availability_zones.available.names[0]
  count             = var.ec2_instance_count
  instance_type     = var.ec2_instance_type
  key_name          = module.key_management.ssh_key_name

  # Network Setup
  # NOTE: Required when explicit aws_network_interface resource is defined
  # network_interface {
  #   network_interface_id = aws_network_interface.ipv6_if.id
  #   device_index         = 0
  # }

  depends_on = [
    module.key_management,
    module.vpc
  ]
  enable_primary_ipv6    = true
  ipv6_address_count     = 1
  subnet_id              = element(module.vpc.subnet_ids, 0)
  vpc_security_group_ids = [module.vpc.security_group_id]

  # Set this to true if you want IPv6 + IPv4 internet connectivity
  # associate_public_ip_address = false
  associate_public_ip_address = true

  # Storage Setup
  # Uncomment if using S3 bucket with defined IAM role & policy
  # iam_instance_profile = try(data.aws_iam_instance_profile.s3bucket_profile.name, null)

  # Lifecycle Setup
  lifecycle {
    create_before_destroy = false
    prevent_destroy       = false
  }

  # Provisioning Setup
  user_data = <<-EOT
        #!/bin/sh
        echo "Welcome to $(hostname)" > /etc/motd.d/${var.tag_name}

        # sshd service config
        echo 'Port "${module.vpc.ssh_port}"' > /etc/ssh/sshd_config.d/${var.tag_name}.conf
        echo 'PermitRootLogin no' >> /etc/ssh/sshd_config.d/${var.tag_name}.conf
        echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config.d/${var.tag_name}.conf
        if [[ "debian" == "$(grep -E "^ID_LIKE=" /etc/os-release | cut -d '=' -f 2 | tr -d '"')" ]]; then
          systemctl restart ssh
        elif [[ "fedora" == "$(grep -E "^ID_LIKE=" /etc/os-release | cut -d '=' -f 2 | tr -d '"')" ]]; then
          systemctl restart sshd
        else
          echo "INFO: Unidentified OS family"
        fi
  EOT

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = module.key_management.ssh_private_key
    host        = element(self.ipv6_addresses, 0)
    port        = module.vpc.ssh_port
    agent       = false
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /tmp/setup"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/../scripts/"
    destination = "/tmp/setup"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod -R +x /tmp/setup",
      "DEFAULT_USER=root DEFAULT_USER_PASSWORD=\"${var.default_user_password}\" /tmp/setup/amazon_linux_2023_setup.sh"
    ]
  }

  # Resource Tagging
  tags = {
    Name = var.tag_name
  }
}
