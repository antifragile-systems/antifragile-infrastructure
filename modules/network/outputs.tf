output "aws_vpc_id" {
  value = "${aws_vpc.antifragile-infrastructure.id}"
}

output "aws_vpc_private_subnet_ids" {
  value = [
    "${module.private_subnets.aws_vpc_subnet_ids}",
  ]
}

output "aws_vpc_public_subnet_ids" {
  value = [
    "${module.public_subnets.aws_vpc_subnet_ids}",
  ]
}

output "aws_vpc_default_security_group_id" {
  value = "${aws_vpc.antifragile-infrastructure.default_security_group_id}"
}

output "aws_nat_security_group_id" {
  value = "${module.gateways.aws_nat_security_group_id}"
}

output "aws_vpn_security_group_id" {
  value = "${module.gateways.aws_vpn_security_group_id}"
}
