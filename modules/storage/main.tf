resource "aws_kms_key" "antifragile-infrastructure" {
  enable_key_rotation = "true"
}

resource "aws_kms_alias" "antifragile-infrastructure" {
  name          = "alias/antifragile-infrastructure/elasticfilesystem"
  target_key_id = "${aws_kms_key.antifragile-infrastructure.key_id}"
}

resource "aws_efs_file_system" "antifragile-infrastructure" {
  encrypted  = "true"
  kms_key_id = "${aws_kms_key.antifragile-infrastructure.arn}"

  tags {
    Name = "${var.name}"
  }
}

resource "aws_security_group" "antifragile-infrastructure" {
  name_prefix = "${var.name}.efs."
  description = "${var.name} efs security group"
  vpc_id      = "${var.aws_vpc_id}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_efs_mount_target" "antifragile-infrastructure" {
  count          = "3"
  file_system_id = "${aws_efs_file_system.antifragile-infrastructure.id}"
  subnet_id      = "${element(var.aws_vpc_private_subnet_ids, count.index)}"

  security_groups = [
    "${aws_security_group.antifragile-infrastructure.id}",
  ]
}
