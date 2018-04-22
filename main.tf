provider "aws" {
  region = "${var.aws_region}"
}

terraform {
  required_version = ">= 0.9.3, != 0.9.5"
}

module "network" {
  source = "./modules/network"

  name           = "${var.name}"
  aws_cidr_block = "${var.cidr_block}"
}

module "storage" {
  source = "./modules/storage"

  name               = "${var.name}"
  aws_vpc_id         = "${module.network.aws_vpc_id}"
  aws_vpc_subnet_ids = "${module.network.aws_vpc_subnet_ids}"
  aws_cidr_block     = "${var.cidr_block}"
}

module "cluster" {
  source = "./modules/cluster"

  name                                   = "${var.name}"
  aws_region                             = "${var.aws_region}"
  aws_ec2_instance_type                  = "${var.aws_ec2_instance_type}"
  aws_ec2_ami                            = "${var.aws_ec2_ami}"
  aws_ec2_public_key                     = "${var.public_key}"
  aws_vpc_id                             = "${module.network.aws_vpc_id}"
  aws_vpc_subnet_ids                     = "${module.network.aws_vpc_subnet_ids}"
  aws_efs_file_system_id                 = "${module.storage.aws_efs_file_system_id}"
  aws_autoscaling_group_min_size         = "${var.cluster_min_size}"
  aws_autoscaling_group_max_size         = "${var.cluster_max_size}"
  aws_autoscaling_group_desired_capacity = "${var.cluster_desired_capacity}"
}
