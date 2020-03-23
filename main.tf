terraform {
  required_version = ">= 0.12"

  backend "s3" {
  }
}

provider "aws" {
  version = "2.54.0"

  region = var.aws_region
}

provider "aws" {
  version = "2.54.0"

  alias  = "global"
  region = "us-east-1"
}

provider "template" {
  version = "2.1.2"
}

resource "aws_key_pair" "antifragile-infrastructure" {
  key_name_prefix = "${var.name}."
  public_key      = var.public_key
}

module "network" {
  source = "./modules/network"

  name                            = var.name
  domain_name                     = var.domain_name
  cidr_block                      = var.cidr_block
  vpn_customer_gateway_hostname   = var.vpn_customer_gateway_hostname
  vpn_customer_gateway_cidr_block = var.vpn_customer_gateway_cidr_block
  vpn_customer_gateway_psk        = var.vpn_customer_gateway_psk
  aws_ec2_public_key_name         = aws_key_pair.antifragile-infrastructure.key_name
}

module "storage" {
  source = "./modules/storage"

  name                         = var.name
  aws_vpc_id                   = module.network.aws_vpc_id
  aws_vpc_private_subnet_ids   = module.network.aws_vpc_private_subnet_ids
  aws_cidr_block               = var.cidr_block
  aws_cloudwatch_log_group_arn = module.monitor.aws_cloudwatch_log_group_arn

  sync_agent_ip_address = var.sync_agent_ip_address
  sync_server_hostname  = var.sync_server_hostname

  database_master_username = var.database_master_username
  database_master_password = var.database_master_password
}

module "cluster" {
  source = "./modules/cluster"

  name                                   = var.name
  domain_name                            = var.domain_name
  aws_region                             = var.aws_region
  aws_ec2_instance_type                  = var.aws_ec2_instance_type
  aws_ec2_ami                            = var.aws_ec2_ami
  aws_ec2_public_key_name                = aws_key_pair.antifragile-infrastructure.key_name
  aws_vpc_id                             = module.network.aws_vpc_id
  aws_vpc_private_subnet_ids             = module.network.aws_vpc_private_subnet_ids
  aws_vpc_public_subnet_ids              = module.network.aws_vpc_public_subnet_ids
  aws_efs_file_system_id                 = module.storage.aws_efs_file_system_id
  aws_autoscaling_group_min_size         = var.cluster_min_size
  aws_autoscaling_group_max_size         = var.cluster_max_size
  aws_autoscaling_group_desired_capacity = var.cluster_desired_capacity
}

resource "aws_security_group_rule" "antifragile-infrastructure" {
  type      = "ingress"
  from_port = 2049

  # nfs
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = module.cluster.aws_launch_configuration_security_group_id
  security_group_id        = module.storage.aws_efs_security_group_id
}

resource "aws_security_group_rule" "allow_mysql_traffic_to_database_from_server" {
  type      = "ingress"
  from_port = 3306

  # mysql
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.cluster.aws_launch_configuration_security_group_id
  security_group_id        = module.storage.aws_database_security_group_id
}

resource "aws_security_group_rule" "allow_mysql_traffic_to_database_from_vpn" {
  type      = "ingress"
  from_port = 3306

  # mysql
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.network.aws_vpn_security_group_id
  security_group_id        = module.storage.aws_database_security_group_id
}

resource "aws_security_group_rule" "allow_all_traffic_to_nat_from_cluster" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = module.cluster.aws_launch_configuration_security_group_id
  security_group_id        = module.network.aws_nat_security_group_id
}

resource "aws_security_group_rule" "allow_all_traffic_to_vpn_from_cluster" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = module.cluster.aws_launch_configuration_security_group_id
  security_group_id        = module.network.aws_vpn_security_group_id
}


resource "aws_security_group_rule" "allow_all_traffic_to_cluster_from_vpn" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = module.network.aws_vpn_security_group_id
  security_group_id        = module.cluster.aws_launch_configuration_security_group_id
}

resource "aws_security_group_rule" "allow_all_traffic_to_nat_from_lambda" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = module.cluster.aws_lambda_security_group_id
  security_group_id        = module.network.aws_nat_security_group_id
}

resource "aws_security_group_rule" "allow_all_traffic_to_vpn_from_lambda" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = module.cluster.aws_lambda_security_group_id
  security_group_id        = module.network.aws_vpn_security_group_id
}

resource "aws_security_group_rule" "allow_all_traffic_to_lambda_from_vpn" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = module.network.aws_vpn_security_group_id
  security_group_id        = module.cluster.aws_lambda_security_group_id
}

resource "aws_security_group_rule" "allow_all_traffic_to_nat_from_vpn" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = module.network.aws_vpn_security_group_id
  security_group_id        = module.network.aws_nat_security_group_id
}

module "api" {
  source = "./modules/api"

  providers = {

  }

  name              = var.name
  domain_name       = var.domain_name
  aws_sns_topic_arn = module.monitor.aws_sns_topic_arn
}

module "monitor" {
  source = "./modules/monitor"

  providers = {
    aws.global = aws.global
  }

  name = var.name
}

module "identity" {
  source = "./modules/identity"

  name = var.name
}

