resource "aws_security_group" "antifragile-infrastructure" {
  name_prefix = "${var.name}.database."
  description = var.name
  vpc_id      = var.aws_vpc_id

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    IsAntifragile = true
    Name          = "database"
  }
}

resource "aws_db_subnet_group" "antifragile-infrastructure" {
  name_prefix = "${var.name}."
  subnet_ids  = var.aws_database_subnet_ids

  tags = {
    IsAntifragile = true
  }
}

resource "aws_ssm_parameter" "username" {
  name = "/${var.name}/database/master_username"
  type = "String"

  value = var.database_master_username

  tags = {
    IsAntifragile = true
  }
}

resource "aws_ssm_parameter" "password" {
  name = "/${var.name}/database/master_password"
  type = "SecureString"

  value = var.database_master_password

  tags = {
    IsAntifragile = true
  }
}

resource "aws_db_instance" "antifragile-infrastructure" {
  instance_class = "db.t3.micro"
  engine         = "mysql"
  engine_version = "5.7"

  identifier = var.name

  storage_type      = "standard"
  allocated_storage = 8

  vpc_security_group_ids = [
    aws_security_group.antifragile-infrastructure.id,
  ]
  db_subnet_group_name = aws_db_subnet_group.antifragile-infrastructure.name

  username = var.database_master_username
  password = var.database_master_password

  apply_immediately = true

  tags = {
    IsAntifragile = true
  }
}

