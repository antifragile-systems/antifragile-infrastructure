resource "aws_security_group" "antifragile-infrastructure" {
  name        = "http"
  description = "http"
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

  subnets = [
    "${var.aws_vpc_subnet_ids}",
  ]

  security_groups = [
    "${aws_security_group.antifragile-infrastructure.id}",
  ]
}

resource "aws_alb_listener" "antifragile-infrastructure" {
  load_balancer_arn = "${aws_alb.antifragile-infrastructure.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.antifragile-infrastructure.id}"
  }
}
