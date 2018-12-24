output "aws_nat_instance_id" {
  value = "${aws_spot_instance_request.nat.spot_instance_id}"
}

output "aws_nat_security_group_id" {
  value = "${aws_security_group.antifragile-infrastructure.id}"
}
