# output "availabililty_zone" {
#   value = random_integer.az.result
# }

output "aws_key_pair_name" {
  value = data.aws_key_pair.ssh_key_pair.key_name
}

# output "aws_subnets" {
#   value = element(data.aws_subnets.ipv6_subnet.ids, 0)
# }

# output "aws_security_groups" {
#   value = element(data.aws_security_groups.allow_ssh.ids, 0)
# }

# output "aws_vpc_security_group_rules" {
#   value = data.aws_vpc_security_group_rule.ssh_ingress.to_port
# }

output "public_ipv6_address" {
  value = aws_instance.linux_server.*.ipv6_addresses
}
