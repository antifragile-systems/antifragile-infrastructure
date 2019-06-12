output "aws_ecs_cluster_id" {
  value = aws_ecs_cluster.antifragile-infrastructure.id
}

output "aws_launch_configuration_security_group_id" {
  value = module.servers.aws_launch_configuration_security_group_id
}

output "aws_lambda_security_group_id" {
  value = module.serverless.aws_lambda_security_group_id
}

