data "aws_kms_key" "antifragile-infrastructure" {
  key_id = "alias/aws/elasticfilesystem"
}

resource "aws_efs_file_system" "antifragile-infrastructure" {
  encrypted  = "true"
  kms_key_id = data.aws_kms_key.antifragile-infrastructure.arn

  tags = {
    Name          = var.name
    IsAntifragile = true
  }
}

resource "aws_security_group" "antifragile-infrastructure" {
  name_prefix = "${var.name}.efs."
  description = "${var.name} efs security group"
  vpc_id      = var.aws_vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_efs_mount_target" "antifragile-infrastructure" {
  count          = "3"
  file_system_id = aws_efs_file_system.antifragile-infrastructure.id
  subnet_id      = var.aws_vpc_private_subnet_ids[ count.index ]

  security_groups = [
    aws_security_group.antifragile-infrastructure.id,
  ]
}

resource "aws_s3_bucket" "antifragile-infrastructure" {
  bucket_prefix = "${var.name}."
  acl           = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  lifecycle_rule {
    id      = "log"
    enabled = true

    prefix = "log/"

    tags = {
      "rule"      = "log"
      "autoclean" = "true"
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }

  tags = {
    IsAntifragile = true
  }
}


data "aws_elb_service_account" "current" {

}

data "aws_caller_identity" "current" {
}

resource "aws_s3_bucket_policy" "log" {
  bucket = aws_s3_bucket.antifragile-infrastructure.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_elb_service_account.current.arn}"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.antifragile-infrastructure.id}/log/loadbalancer/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_caller_identity.current.arn}"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.antifragile-infrastructure.id}/log/storage/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_caller_identity.current.arn}"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.antifragile-infrastructure.id}/log/cdn/*"
    }
  ]
}
EOF
}

module "sync" {
  source = "./modules/sync"

  name                = var.name
  agent_ip_address    = var.sync_agent_ip_address
  nfs_server_hostname = var.sync_server_hostname

  aws_vpc_id                   = var.aws_vpc_id
  aws_efs_mount_target_id      = aws_efs_mount_target.antifragile-infrastructure[ 0 ].id
  aws_efs_security_group_id    = aws_security_group.antifragile-infrastructure.id
  aws_cloudwatch_log_group_arn = var.aws_cloudwatch_log_group_arn
}

module "database" {
  source = "./modules/database"

  name = var.name

  aws_vpc_id              = var.aws_vpc_id
  aws_database_subnet_ids = var.aws_vpc_private_subnet_ids

  database_master_username = var.database_master_username
  database_master_password = var.database_master_password
}

module "backup" {
  source = "./modules/backup"

  name = var.name
}
