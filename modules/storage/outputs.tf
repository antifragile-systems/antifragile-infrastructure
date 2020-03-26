output "aws_efs_file_system_id" {
  value = aws_efs_file_system.antifragile-infrastructure.id
}

output "aws_efs_security_group_id" {
  value = aws_security_group.antifragile-infrastructure.id
}

output "aws_database_security_group_id" {
  value = module.database.aws_database_security_group_id
}

output "aws_s3_bucket" {
  value = aws_s3_bucket.antifragile-infrastructure.id
}
