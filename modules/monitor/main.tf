provider "aws" {
  alias = "global"
}

resource "aws_cloudwatch_log_group" "antifragile-infrastructure" {
  name              = var.name
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "antifragile-infrastructure-1" {
  provider = aws.global

  name              = var.name
  retention_in_days = 30
}

resource "aws_sns_topic" "antifragile-infrastructure" {
  provider = aws.global

  name = var.name
}

resource "aws_sns_topic" "antifragile-infrastructure-1" {
  name = var.name
}

