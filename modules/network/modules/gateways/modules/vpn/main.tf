locals {
  hostname = "vpn.${var.domain_name}"
}

resource "aws_security_group" "antifragile-infrastructure" {
  name_prefix = "${var.name}.vpn."
  description = "${var.name} vpn security group"
  vpc_id      = var.aws_vpc_id

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
      "::/0",
    ]
  }
}

resource "aws_security_group_rule" "antifragile-infrastructure" {
  type                     = "ingress"
  from_port                = 4500
  to_port                  = 4500
  protocol                 = "udp"
  security_group_id        = aws_security_group.antifragile-infrastructure.id

  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

data "template_file" "user_data" {
  template = file("${path.module}/user-data.yml")

  vars = {
    hostname                    = local.hostname
    cidr_block                  = var.cidr_block
    customer_gateway_hostname   = var.vpn_customer_gateway_hostname
    customer_gateway_cidr_block = var.vpn_customer_gateway_cidr_block
    customer_gateway_psk        = var.vpn_customer_gateway_psk
  }
}

resource "aws_spot_instance_request" "vpn" {
  ami           = var.aws_ec2_vpn_ami
  instance_type = var.aws_ec2_vpn_instance_type
  key_name      = var.aws_ec2_public_key_name

  spot_price           = "0.0051"
  spot_type            = "persistent"
  wait_for_fulfillment = true

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.vpn.id
  }

  user_data = data.template_file.user_data.rendered

  credit_specification {
    cpu_credits = "standard"
  }
  # https://github.com/terraform-providers/terraform-provider-aws/issues/5651
}

resource "aws_eip" "vpn" {
  vpc = true
}

resource "aws_network_interface" "vpn" {
  subnet_id       = var.aws_vpc_public_subnet_ids[ 0 ]
  security_groups = [
    aws_security_group.antifragile-infrastructure.id
  ]

  source_dest_check = false
}

resource "aws_eip_association" "vpn" {
  allocation_id = aws_eip.vpn.id

  network_interface_id = aws_network_interface.vpn.id
}

data "aws_route53_zone" "selected" {
  name         = "${var.domain_name}."
  private_zone = false
}

resource "aws_route53_record" "antifragile-infrastructure" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = local.hostname
  type    = "A"
  ttl     = "300"

  records = [
    aws_eip.vpn.public_ip,
  ]
}

