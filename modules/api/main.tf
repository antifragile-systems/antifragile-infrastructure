locals {
  hostname = "api.${var.domain_name}"
}

data "aws_route53_zone" "selected" {
  name         = "${var.domain_name}."
  private_zone = false
}

module "certificate" {
  source = "../certificate"

  name                = var.name
  aws_route53_zone_id = data.aws_route53_zone.selected.id
  domain_name         = local.hostname
  aws_region          = "us-east-1"
}

resource "aws_api_gateway_rest_api" "antifragile-infrastructure" {
  name = var.name
}

resource "aws_api_gateway_resource" "antifragile-infrastructure" {
  rest_api_id = aws_api_gateway_rest_api.antifragile-infrastructure.id
  parent_id   = aws_api_gateway_rest_api.antifragile-infrastructure.root_resource_id
  path_part   = "ping"
}

resource "aws_api_gateway_method" "antifragile-infrastructure" {
  rest_api_id   = aws_api_gateway_rest_api.antifragile-infrastructure.id
  resource_id   = aws_api_gateway_resource.antifragile-infrastructure.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "antifragile-infrastructure" {
  rest_api_id = aws_api_gateway_rest_api.antifragile-infrastructure.id
  resource_id = aws_api_gateway_resource.antifragile-infrastructure.id
  http_method = aws_api_gateway_method.antifragile-infrastructure.http_method
  type        = "MOCK"
}

resource "aws_api_gateway_method_response" "antifragile-infrastructure" {
  rest_api_id = aws_api_gateway_rest_api.antifragile-infrastructure.id
  resource_id = aws_api_gateway_resource.antifragile-infrastructure.id
  http_method = aws_api_gateway_method.antifragile-infrastructure.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "antifragile-infrastructure" {
  rest_api_id = aws_api_gateway_rest_api.antifragile-infrastructure.id
  resource_id = aws_api_gateway_resource.antifragile-infrastructure.id
  http_method = aws_api_gateway_method.antifragile-infrastructure.http_method
  status_code = aws_api_gateway_method_response.antifragile-infrastructure.status_code
}

resource "aws_api_gateway_deployment" "antifragile-infrastructure" {
  depends_on = [aws_api_gateway_integration.antifragile-infrastructure]

  rest_api_id = aws_api_gateway_rest_api.antifragile-infrastructure.id
  stage_name  = "production"
}

resource "aws_api_gateway_stage" "antifragile-infrastructure" {
  stage_name    = "production"
  rest_api_id   = aws_api_gateway_rest_api.antifragile-infrastructure.id
  deployment_id = aws_api_gateway_deployment.antifragile-infrastructure.id

  variables = {
    "deployed_at" = timestamp()
    "host"        = "api.${var.domain_name}"
  }

  xray_tracing_enabled = true

  lifecycle {
    ignore_changes = [
      variables,
      deployment_id
    ]
  }
}

resource "aws_api_gateway_domain_name" "antifragile-infrastructure" {
  domain_name = local.hostname

  certificate_arn = module.certificate.aws_acm_certificate_arn
}

resource "aws_api_gateway_base_path_mapping" "antifragile-infrastructure" {
  api_id      = aws_api_gateway_rest_api.antifragile-infrastructure.id
  stage_name  = "production"
  domain_name = local.hostname

  depends_on = [aws_api_gateway_stage.antifragile-infrastructure]
}

resource "aws_route53_record" "antifragile-infrastructure" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = local.hostname
  type    = "CNAME"
  ttl     = "300"

  records = [
    aws_api_gateway_domain_name.antifragile-infrastructure.cloudfront_domain_name,
  ]
}

resource "aws_cloudwatch_metric_alarm" "antifragile-infrastructure-1" {
  alarm_name = "api server error"

  metric_name = "5XXError"
  namespace   = "AWS/ApiGateway"

  dimensions = {
    ApiName = var.name
  }

  threshold           = 2
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  period              = 60
  statistic           = "Sum"
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    var.aws_sns_topic_arn
  ]
  ok_actions    = [
    var.aws_sns_topic_arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "antifragile-infrastructure" {
  alarm_name = "api client error"

  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = 2
  treat_missing_data  = "notBreaching"

  threshold_metric_id = "e1"

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1)"
    label       = "4XXError (Expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"

    metric {
      metric_name = "4XXError"
      namespace   = "AWS/ApiGateway"
      period      = 60
      stat        = "Sum"

      dimensions = {
        ApiName = var.name
      }
    }
  }

  alarm_actions = [
    var.aws_sns_topic_arn
  ]
  ok_actions    = [
    var.aws_sns_topic_arn
  ]
}
