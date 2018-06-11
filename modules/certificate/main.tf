provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_acm_certificate" "antifragile-infrastructure" {
  domain_name               = "${var.domain_name}"
  subject_alternative_names = "${var.subject_alternative_names}"
  validation_method         = "DNS"
}

resource "aws_route53_record" "antifragile-infrastructure" {
  name    = "${aws_acm_certificate.antifragile-infrastructure.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.antifragile-infrastructure.domain_validation_options.0.resource_record_type}"
  zone_id = "${var.aws_route53_zone_id}"

  records = [
    "${aws_acm_certificate.antifragile-infrastructure.domain_validation_options.0.resource_record_value}",
  ]

  ttl = 60
}

resource "aws_acm_certificate_validation" "antifragile-infrastructure" {
  certificate_arn = "${aws_acm_certificate.antifragile-infrastructure.arn}"

  validation_record_fqdns = [
    "${aws_route53_record.antifragile-infrastructure.fqdn}",
  ]
}
