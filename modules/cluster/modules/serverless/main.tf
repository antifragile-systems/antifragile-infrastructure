resource "aws_security_group" "antifragile-infrastructure" {
  name_prefix = "${var.name}.serverless."
  description = "${var.name} serverless security group"
  vpc_id      = "${var.aws_vpc_id}"

  lifecycle {
    create_before_destroy = true
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = [
      "::/0" ]
  }

  tags {
    IsAntifragile = true
    Name          = "serverless"
  }
}
