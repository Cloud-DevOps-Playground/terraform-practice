output "ssh_key_name" {
  value = aws_key_pair.ssh_key_pair.key_name
}

output "ssh_key_file" {
  value = local_sensitive_file.pem_file.filename
}

output "ssh_private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}