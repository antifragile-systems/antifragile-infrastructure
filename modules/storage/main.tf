resource "aws_kms_key" "antifragile-infrastructure" {}

resource "aws_efs_file_system" "antifragile-infrastructure" {
  encrypted  = "true"
  kms_key_id = "${aws_kms_key.antifragile-infrastructure.arn}"

  tags {
    Name = "${var.name}"
  }
}

resource "aws_security_group" "antifragile-infrastructure" {
  name        = "efs"
  description = "EFS"
  vpc_id      = "${var.aws_vpc_id}"

  lifecycle {
    create_before_destroy = true
  }

  # nfs
  ingress {
    from_port = "2049"
    to_port   = "2049"
    protocol  = "tcp"

    security_groups = [
      "${var.aws_vpc_default_security_group_id}",
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

resource "aws_efs_mount_target" "antifragile-infrastructure" {
  count          = "3"
  file_system_id = "${aws_efs_file_system.antifragile-infrastructure.id}"
  subnet_id      = "${element(var.aws_vpc_subnet_ids, count.index)}"

  security_groups = [
    "${aws_security_group.antifragile-infrastructure.id}",
  ]
}
