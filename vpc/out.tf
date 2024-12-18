output "instance_ipv6_address" {
  description = "Public IP address of the EC2 instance"
  value       = [for ipv6_address in aws_instance.linux_server.ipv6_addresses : ipv6_address]
  # sensitive   = true
}
