resource "aws_cloudwatch_log_group" "antifragile-infrastructure" {
  name              = "${var.name}"
  retention_in_days = 30
}
