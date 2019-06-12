resource "aws_datasync_agent" "antifragile-infrastructure" {
  ip_address = var.agent_ip_address
  name       = var.name
}

data "aws_efs_mount_target" "selected" {
  mount_target_id = var.aws_efs_mount_target_id
}

data "aws_subnet" "selected" {
  id = data.aws_efs_mount_target.selected.subnet_id
}

resource "aws_security_group" "antifragile-infrastructure" {
  name_prefix = "${var.name}.sync."
  description = "${var.name} sync security group"
  vpc_id      = var.aws_vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_all_traffic_from_sync_to_efs" {
  type      = "egress"
  from_port = 2049

  # nfs
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = var.aws_efs_security_group_id
  security_group_id        = aws_security_group.antifragile-infrastructure.id
}

resource "aws_security_group_rule" "allow_all_traffic_to_efs_from_sync" {
  type      = "ingress"
  from_port = 2049

  # nfs
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.antifragile-infrastructure.id
  security_group_id        = var.aws_efs_security_group_id
}

resource "aws_datasync_location_efs" "antifragile-infrastructure" {
  efs_file_system_arn = data.aws_efs_mount_target.selected.file_system_arn

  ec2_config {
    security_group_arns = [
      aws_security_group.antifragile-infrastructure.arn,
    ]
    subnet_arn = data.aws_subnet.selected.arn
  }
}

resource "aws_datasync_location_nfs" "antifragile-infrastructure" {
  server_hostname = var.nfs_server_hostname
  subdirectory    = "/AWS/efs/${data.aws_efs_mount_target.selected.file_system_id}"

  on_prem_config {
    agent_arns = [
      aws_datasync_agent.antifragile-infrastructure.arn,
    ]
  }
}

resource "aws_datasync_task" "antifragile-infrastructure" {
  name = "${var.name}.efs"

  destination_location_arn = aws_datasync_location_nfs.antifragile-infrastructure.arn
  source_location_arn      = aws_datasync_location_efs.antifragile-infrastructure.arn
  cloudwatch_log_group_arn = substr(
    var.aws_cloudwatch_log_group_arn,
    0,
    length(var.aws_cloudwatch_log_group_arn) - 2,
  )

  options {
    preserve_deleted_files = "REMOVE"
  }
}

data "aws_iam_policy_document" "antifragile-infrastructure" {
  statement {
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
    ]

    resources = [
      var.aws_cloudwatch_log_group_arn,
    ]

    principals {
      identifiers = [
        "datasync.amazonaws.com",
      ]
      type = "Service"
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "antifragile-infrastructure" {
  policy_document = data.aws_iam_policy_document.antifragile-infrastructure.json
  policy_name     = "${var.name}.sync"
}

