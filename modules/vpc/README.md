# Create VPC module
Create a VPC with public subnet for IPv6 traffic.

## Notes
- The module automatically detects your public IPv6 address using `http://ipv6.icanhazip.com` and opens the configured SSH port (default 22) from that IP.
- If your environment cannot contact `ipv6.icanhazip.com`, adjust your environment or use a different workflow; the module no longer accepts a `my_ip` variable.

## Outputs
- `vpc_id`
- `subnet_ids`
- `security_group_id`
- `ssh_port`