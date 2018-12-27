output "aws_vpn_instance_id" {
  value = "${aws_spot_instance_request.vpn.spot_instance_id}"
}

output "aws_vpn_security_group_id" {
  value = "${aws_security_group.antifragile-infrastructure.id}"
}
