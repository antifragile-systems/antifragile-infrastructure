output "aws_vpn_network_interface_id" {
  value = aws_network_interface.vpn.id
}

output "aws_vpn_security_group_id" {
  value = aws_security_group.antifragile-infrastructure.id
}

