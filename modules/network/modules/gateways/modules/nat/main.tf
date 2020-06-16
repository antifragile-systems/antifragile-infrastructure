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

resource "aws_launch_template" "nat" {
  name_prefix = "${var.name}.nat."

  image_id = var.aws_ec2_nat_ami
  instance_type = var.aws_ec2_nat_instance_type
  key_name      = var.aws_ec2_public_key_name

  instance_market_options {
    market_type = "spot"

    spot_options {
      max_price = "0.0051"
      spot_instance_type = "one-time"
    }
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    device_index         = 0
    network_interface_id = aws_network_interface.nat.id
  }
}

data "aws_subnet" "selected" {
  id = var.aws_vpc_public_subnet_ids[ 0 ]
}

resource "aws_autoscaling_group" "vpn" {
  name_prefix = "${var.name}.nat."

  min_size = 1
  max_size = 1
  desired_capacity = 1

  availability_zones = [ data.aws_subnet.selected.availability_zone ]

  launch_template {
    id      = aws_launch_template.nat.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_network_interface" "nat" {
  subnet_id       = var.aws_vpc_public_subnet_ids[0]
  security_groups = [
    aws_security_group.antifragile-infrastructure.id
  ]

  source_dest_check = false
}

resource "aws_eip_association" "nat" {
  allocation_id = aws_eip.nat.id

  network_interface_id = aws_network_interface.nat.id
}
