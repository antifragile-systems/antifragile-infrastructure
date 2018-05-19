locals {
  hostname = "api.${var.domain}"
}

data "aws_route53_zone" "selected" {
  name         = "${var.domain}."
  private_zone = false
}

module "certificate" {
  source = "./modules/certificate"

  name                = "${var.name}"
  aws_route53_zone_id = "${data.aws_route53_zone.selected.id}"
  hostname            = "${local.hostname}"
}

resource "aws_api_gateway_rest_api" "antifragile-infrastructure" {
  name = "${var.name}"
}

resource "aws_api_gateway_deployment" "antifragile-service" {
  rest_api_id = "${aws_api_gateway_rest_api.antifragile-infrastructure.id}"
  stage_name  = "production"
}

resource "aws_api_gateway_stage" "antifragile-infrastructure" {
  stage_name    = "production"
  rest_api_id   = "${aws_api_gateway_rest_api.antifragile-infrastructure.id}"
  deployment_id = "${aws_api_gateway_deployment.antifragile-service.id}"
}

resource "aws_api_gateway_domain_name" "antifragile-infrastructure" {
  domain_name = "${local.hostname}"

  certificate_arn = "${module.certificate.aws_acm_certificate_arn}"
}

resource "aws_api_gateway_base_path_mapping" "antifragile-infrastructure" {
  api_id      = "${aws_api_gateway_rest_api.antifragile-infrastructure.id}"
  stage_name  = "production"
  domain_name = "${local.hostname}"
  base_path   = "/"

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
