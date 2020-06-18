data "template_file" "user_data" {
  template = file("${path.module}/user-data.yml")

  vars = {
    region            = var.aws_region
    ecs_cluster_name  = var.name
    efs_filesystem_id = var.aws_efs_file_system_id
  }
}

resource "aws_iam_role" "antifragile-infrastructure" {
  name = "${var.name}.ECSInstanceRole"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "antifragile-infrastructure" {
  role       = aws_iam_role.antifragile-infrastructure.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "antifragile-infrastructure" {
  name_prefix = "${var.name}."
  role        = aws_iam_role.antifragile-infrastructure.name
}

resource "aws_security_group" "antifragile-infrastructure" {
  name_prefix = "${var.name}.servers."
  description = var.name
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

resource "aws_launch_template" "servers" {
  name_prefix = "${var.name}.servers."

  image_id      = var.aws_ec2_ami
  instance_type = var.aws_ec2_instance_type
  key_name      = var.aws_ec2_public_key_name

  user_data = base64encode(data.template_file.user_data.rendered)

  vpc_security_group_ids = [
    aws_security_group.antifragile-infrastructure.id ]

  iam_instance_profile {
    name = aws_iam_instance_profile.antifragile-infrastructure.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 30
      volume_type           = "standard"
      delete_on_termination = true
    }
  }

  instance_market_options {
    market_type = "spot"

    spot_options {
      max_price          = "0.0102"
      spot_instance_type = "one-time"
    }
  }

  monitoring {
    enabled = false
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "antifragile-infrastructure" {
  name_prefix = "${var.name}.servers."

  min_size         = var.aws_autoscaling_group_min_size
  max_size         = var.aws_autoscaling_group_max_size
  desired_capacity = var.aws_autoscaling_group_desired_capacity

  vpc_zone_identifier = var.aws_vpc_private_subnet_ids

  launch_template {
    id      = aws_launch_template.servers.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }
}

