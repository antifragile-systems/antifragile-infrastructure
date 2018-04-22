output "aws_efs_file_system_id" {
  value = "${aws_efs_file_system.antifragile-systems.id}"
}

output "aws_efs_security_group_id" {
  value = "${aws_security_group.antifragile-systems.id}"
}
