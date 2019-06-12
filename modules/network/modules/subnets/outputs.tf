output "aws_vpc_subnet_ids" {
  value = aws_subnet.antifragile-infrastructure.*.id
}

