output "aws_internet_gateway_id" {
  value = "${aws_internet_gateway.antifragile-infrastructure.id}"
}

output "aws_egress_only_internet_gateway_id" {
  value = "${aws_egress_only_internet_gateway.antifragile-infrastructure.id}"
}

output "aws_nat_instance_id" {
  value = "${module.nat.aws_nat_instance_id}"
}

output "aws_nat_security_group_id" {
  value = "${module.nat.aws_nat_security_group_id}"
}
