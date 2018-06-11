resource "aws_security_group" "antifragile-infrastructure" {
  name_prefix = "loadbalancer."
  description = "loadbalancer"
  vpc_id      = "${var.aws_vpc_id}"

  lifecycle {
    create_before_destroy = true
  }

  # http
  ingress {
    from_port = "80"
    to_port   = "80"
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  # https
  ingress {
    from_port = "443"
    to_port   = "443"
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

resource "aws_alb_target_group" "antifragile-infrastructure" {
  name     = "${var.name}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.aws_vpc_id}"
}

resource "aws_alb" "antifragile-infrastructure" {
  name = "${var.name}"

  internal = false

  subnets = [
    "${var.aws_vpc_subnet_ids}",
  ]

  security_groups = [
    "${aws_security_group.antifragile-infrastructure.id}",
  ]
}

resource "aws_alb_listener" "antifragile-infrastructure-0" {
  load_balancer_arn = "${aws_alb.antifragile-infrastructure.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.antifragile-infrastructure.id}"
  }
}

data "aws_route53_zone" "selected" {
  name         = "${var.domain_name}."
  private_zone = false
}

module "certificate" {
  source = "../../../certificate"

  name                = "${var.name}"
  aws_route53_zone_id = "${data.aws_route53_zone.selected.id}"
  domain_name         = "${var.domain_name}"

  subject_alternative_names = [
    "*.${var.domain_name}",
  ]

  aws_region = "${var.aws_region}"
}

resource "aws_alb_listener" "antifragile-infrastructure-1" {
  load_balancer_arn = "${aws_alb.antifragile-infrastructure.id}"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "${module.certificate.aws_acm_certificate_arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.antifragile-infrastructure.id}"
  }
}
