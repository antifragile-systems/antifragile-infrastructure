data "template_file" "user_data" {
  template = "${file("${path.module}/user-data.yml")}"

  vars {
    region            = "${var.aws_region}"
    ecs_cluster_name  = "${var.name}"
    efs_filesystem_id = "${var.aws_efs_file_system_id}"
  }
}

resource "aws_key_pair" "antifragile-infrastructure" {
  key_name_prefix = "${var.name}."
  public_key      = "${var.aws_ec2_public_key}"
}

resource "aws_iam_role" "antifragile-infrastructure" {
  name_prefix        = "${var.name}."
  assume_role_policy = "${file("${path.module}/ec2-instance-role.json")}"
}

resource "aws_iam_role_policy_attachment" "antifragile-infrastructure-1" {
  role      = "${aws_iam_role.antifragile-infrastructure.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_role_policy_attachment" "antifragile-infrastructure-2" {
  role      = "${aws_iam_role.antifragile-infrastructure.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "antifragile-infrastructure" {
  name_prefix = "${var.name}."
  role        = "${aws_iam_role.antifragile-infrastructure.name}"
}

resource "aws_security_group" "antifragile-infrastructure" {
  name_prefix = "${var.name}."
  description = "${var.name}"
  vpc_id      = "${var.aws_vpc_id}"

  lifecycle {
    create_before_destroy = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

resource "aws_launch_configuration" "antifragile-infrastructure" {
  name_prefix                 = "${var.name}."

  security_groups             = [
    "${aws_security_group.antifragile-infrastructure.id}",
  ]

  key_name                    = "${aws_key_pair.antifragile-infrastructure.key_name}"
  image_id                    = "${var.aws_ec2_ami}"
  instance_type               = "${var.aws_ec2_instance_type}"
  iam_instance_profile        = "${aws_iam_instance_profile.antifragile-infrastructure.name}"
  user_data                   = "${data.template_file.user_data.rendered}"
  associate_public_ip_address = true
  spot_price                  = "0.0126"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "antifragile-infrastructure" {
  name                 = "${var.name}"

  vpc_zone_identifier  = [
    "${var.aws_vpc_subnet_ids}",
  ]

  launch_configuration = "${aws_launch_configuration.antifragile-infrastructure.name}"
  min_size             = "${var.aws_autoscaling_group_min_size}"
  max_size             = "${var.aws_autoscaling_group_max_size}"
  desired_capacity     = "${var.aws_autoscaling_group_desired_capacity}"

  lifecycle {
    create_before_destroy = true
  }
}
