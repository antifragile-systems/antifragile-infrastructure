locals {
  hostname = "api.${var.domain_name}"
}

data "aws_route53_zone" "selected" {
  name         = "${var.domain_name}."
  private_zone = false
}

module "certificate" {
  source = "../certificate"

  name                = "${var.name}"
  aws_route53_zone_id = "${data.aws_route53_zone.selected.id}"
  domain_name         = "${local.hostname}"
  aws_region          = "us-east-1"
}

resource "aws_api_gateway_rest_api" "antifragile-infrastructure" {
  name = "${var.name}"
}

resource "aws_api_gateway_resource" "antifragile-infrastructure" {
  rest_api_id = "${aws_api_gateway_rest_api.antifragile-infrastructure.id}"
  parent_id   = "${aws_api_gateway_rest_api.antifragile-infrastructure.root_resource_id}"
  path_part   = "ping"
}

resource "aws_api_gateway_method" "antifragile-infrastructure" {
  rest_api_id   = "${aws_api_gateway_rest_api.antifragile-infrastructure.id}"
  resource_id   = "${aws_api_gateway_resource.antifragile-infrastructure.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "antifragile-infrastructure" {
  rest_api_id = "${aws_api_gateway_rest_api.antifragile-infrastructure.id}"
  resource_id = "${aws_api_gateway_resource.antifragile-infrastructure.id}"
  http_method = "${aws_api_gateway_method.antifragile-infrastructure.http_method}"
  type        = "MOCK"
}

resource "aws_api_gateway_method_response" "antifragile-infrastructure" {
  rest_api_id = "${aws_api_gateway_rest_api.antifragile-infrastructure.id}"
  resource_id = "${aws_api_gateway_resource.antifragile-infrastructure.id}"
  http_method = "${aws_api_gateway_method.antifragile-infrastructure.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "antifragile-infrastructure" {
  rest_api_id = "${aws_api_gateway_rest_api.antifragile-infrastructure.id}"
  resource_id = "${aws_api_gateway_resource.antifragile-infrastructure.id}"
  http_method = "${aws_api_gateway_method.antifragile-infrastructure.http_method}"
  status_code = "${aws_api_gateway_method_response.antifragile-infrastructure.status_code}"
}

resource "aws_api_gateway_deployment" "antifragile-infrastructure" {
  rest_api_id = "${aws_api_gateway_rest_api.antifragile-infrastructure.id}"
  stage_name  = "production"
}

resource "aws_api_gateway_stage" "antifragile-infrastructure" {
  stage_name    = "production"
  rest_api_id   = "${aws_api_gateway_rest_api.antifragile-infrastructure.id}"
  deployment_id = "${aws_api_gateway_deployment.antifragile-infrastructure.id}"
}

resource "aws_api_gateway_domain_name" "antifragile-infrastructure" {
  domain_name = "${local.hostname}"

  certificate_arn = "${module.certificate.aws_acm_certificate_arn}"
}

resource "aws_api_gateway_base_path_mapping" "antifragile-infrastructure" {
  api_id      = "${aws_api_gateway_rest_api.antifragile-infrastructure.id}"
  stage_name  = "production"
  domain_name = "${local.hostname}"

  depends_on = [
    "aws_api_gateway_stage.antifragile-infrastructure",
  ]
}

resource "aws_route53_record" "antifragile-infrastructure" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "${local.hostname}"
  type    = "CNAME"
  ttl     = "300"

  records = [
    "${aws_api_gateway_domain_name.antifragile-infrastructure.cloudfront_domain_name}",
  ]
}
