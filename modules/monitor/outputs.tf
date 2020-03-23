output "aws_cloudwatch_log_group_arn" {
  value = aws_cloudwatch_log_group.antifragile-infrastructure.arn
}

output "aws_sns_topic_arn" {
  value = aws_sns_topic.antifragile-infrastructure-1.arn
}
