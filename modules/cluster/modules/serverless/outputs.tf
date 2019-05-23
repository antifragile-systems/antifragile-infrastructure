output "aws_lambda_security_group_id" {
  value = "${aws_security_group.antifragile-infrastructure.id}"
}
