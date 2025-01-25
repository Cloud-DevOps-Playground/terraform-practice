# Dynamically generate a new private key on AWS
resource "tls_private_key" "ssh_key" {
  # algorithm = "ED25519"
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh_key_pair" {
  key_name = var.key_name
  # Use the local public key file
  # public_key = file(".ssh/${var.key_name}.pem.pub")
  public_key = tls_private_key.ssh_key.public_key_openssh

  # Resource Tagging
  tags = {
    Name = var.tag_name
  }
}

# Save the dynamically generated key pair pem file
resource "local_sensitive_file" "pem_file" {
  filename             = "${path.module}/${var.key_name}.pem"
  file_permission      = "400"
  directory_permission = "755"
  content              = tls_private_key.ssh_key.private_key_pem
}

# Maintained for debugging purpose
# resource "local_sensitive_file" "pem_pub_file" {
#   filename             = "${path.module}/${var.key_name}.pem.pub"
#   file_permission      = "644"
#   directory_permission = "755"
#   content              = tls_private_key.ssh_key.public_key_openssh
# }
