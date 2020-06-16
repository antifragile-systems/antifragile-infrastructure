output "aws_nat_network_interface_id" {
  value = aws_network_interface.nat.id
}

output "aws_nat_security_group_id" {
  value = aws_security_group.antifragile-infrastructure.id
}

