resource "aws_kms_key" "antifragile-systems" {}

resource "aws_efs_file_system" "antifragile-systems" {
  encrypted  = "true"
  kms_key_id = "${aws_kms_key.antifragile-systems.arn}"

  tags {
    Name = "${var.name}"
  }
}

resource "aws_security_group" "antifragile-systems" {
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

    cidr_blocks = [
      "${var.aws_cidr_block}",
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

resource "aws_efs_mount_target" "antifragile-systems" {
  count          = "3"
  file_system_id = "${aws_efs_file_system.antifragile-systems.id}"
  subnet_id      = "${element(var.aws_vpc_subnet_ids, count.index)}"

  security_groups = [
    "${aws_security_group.antifragile-systems.id}",
  ]
}
