data "aws_kms_key" "antifragile-infrastructure" {
  key_id = "alias/aws/backup"
}


resource "aws_backup_vault" "antifragile-infrastructure" {
  name = "${var.name}"

  kms_key_arn = "${data.aws_kms_key.antifragile-infrastructure.arn}"

  tags = {
    IsAntifragile = true
  }
}

resource "aws_backup_plan" "antifragile-infrastructure" {
  name = "${var.name}"

  rule {
    rule_name         = "DailyBackups"
    target_vault_name = "${aws_backup_vault.antifragile-infrastructure.name}"
    schedule          = "cron(0 5 ? * * *)"

    lifecycle {
      delete_after = 35
    }
  }

  tags = {
    IsAntifragile = true
  }
}

data "aws_iam_role" "antifragile-infrastructure" {
  name = "AWSBackupDefaultServiceRole"
}

resource "aws_backup_selection" "antifragile-infrastructure" {
  name    = "${var.name}"
  plan_id = "${aws_backup_plan.antifragile-infrastructure.id}"

  iam_role_arn = "${data.aws_iam_role.antifragile-infrastructure.arn}"

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "IsAntifragile"
    value = true
  }
}
