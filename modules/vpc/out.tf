output "vpc_id" {
  value = aws_vpc.ipv6_vpc.id
}

output "subnet_ids" {
  description = "List of subnet ids created for the VPC"
  value       = [aws_subnet.ip_subnet.id]
}

output "security_group_id" {
  description = "Security group id for allow_traffic"
  value       = aws_security_group.allow_traffic.id
}

output "ssh_port" {
  description = "SSH port opened in the security group"
  value       = var.ssh_port
}