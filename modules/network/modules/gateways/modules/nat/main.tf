resource "aws_security_group" "antifragile-infrastructure" {
  name_prefix = "${var.name}.nat."
  description = "${var.name} nat security group"
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
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    ipv6_cidr_blocks = [
      "::/0",
    ]
  }
}

resource "aws_spot_instance_request" "nat" {
  ami                         = var.aws_ec2_nat_ami
  instance_type               = var.aws_ec2_nat_instance_type
  associate_public_ip_address = true
  source_dest_check           = false
  key_name                    = var.aws_ec2_public_key_name
  subnet_id                   = var.aws_vpc_public_subnet_ids[0]

  spot_price           = "0.0051"
  spot_type            = "persistent"
  wait_for_fulfillment = true

  # https://github.com/terraform-providers/terraform-provider-aws/issues/2751

  vpc_security_group_ids = [
    aws_security_group.antifragile-infrastructure.id,
  ]

  credit_specification {
    cpu_credits = "standard"
  }
  # https://github.com/terraform-providers/terraform-provider-aws/issues/5651
}

