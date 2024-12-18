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
