resource "aws_security_group" "antifragile-infrastructure" {
  name_prefix = "${var.name}.loadbalancer."
  description = "${var.name} loadbalancer security group"
  vpc_id      = "${var.aws_vpc_id}"

  lifecycle {
    create_before_destroy = true
  }

  # http
  ingress {
    from_port        = "80"
    to_port          = "80"
    protocol         = "tcp"

    cidr_blocks      = [
      "0.0.0.0/0"
    ]

    ipv6_cidr_blocks = [
      "::/0"
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
  name            = "${var.name}"

  internal        = false

  subnets         = [
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
