locals {
  hostname = "vpn.${var.domain_name}"
}

resource "aws_security_group" "antifragile-infrastructure" {
  name_prefix = "${var.name}.vpn."
  description = "${var.name} vpn security group"
  vpc_id      = "${var.aws_vpc_id}"

  lifecycle {
    create_before_destroy = true
  }

  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = [
      "::/0" ]
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user-data.yml")}"

  vars {
    hostname                  = "${local.hostname}"
    cidr_block                = "${var.cidr_block}"
    customer_gateway_hostname = "${var.vpn_customer_gateway_hostname}"
    customer_gateway_psk      = "${var.vpn_customer_gateway_psk}"
  }
}

resource "aws_spot_instance_request" "vpn" {
  ami                         = "${var.aws_ec2_vpn_ami}"
  instance_type               = "${var.aws_ec2_vpn_instance_type}"
  associate_public_ip_address = true
  source_dest_check           = false
  key_name                    = "${var.aws_ec2_public_key_name}"
  subnet_id                   = "${var.aws_vpc_public_subnet_ids[0]}"

  spot_price           = "0.0057"
  spot_type            = "persistent"
  wait_for_fulfillment = true
  # https://github.com/terraform-providers/terraform-provider-aws/issues/2751

  vpc_security_group_ids      = [
    "${aws_security_group.antifragile-infrastructure.id}" ]

  user_data                   = "${data.template_file.user_data.rendered}"

  credit_specification {
    cpu_credits = "standard"
  }
  # https://github.com/terraform-providers/terraform-provider-aws/issues/5651
}

data "aws_route53_zone" "selected" {
  name         = "${var.domain_name}."
  private_zone = false
}

resource "aws_route53_record" "antifragile-infrastructure" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "${local.hostname}"
  type    = "A"
  ttl     = "300"

  records = [
    "${aws_spot_instance_request.vpn.public_ip}"
  ]
}
