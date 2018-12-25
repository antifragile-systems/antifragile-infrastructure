resource "aws_ecs_cluster" "antifragile-infrastructure" {
  name = "${var.name}"
}

module "loadbalancer" {
  source                    = "./modules/loadbalancer"

  name                      = "${var.name}"
  domain_name               = "${var.domain_name}"
  aws_vpc_id                = "${var.aws_vpc_id}"
  aws_vpc_public_subnet_ids = "${var.aws_vpc_public_subnet_ids}"
  aws_region                = "${var.aws_region}"
}

module "servers" {
  source                                 = "./modules/servers"

  name                                   = "${var.name}"
  aws_region                             = "${var.aws_region}"
  aws_ec2_instance_type                  = "${var.aws_ec2_instance_type}"
  aws_ec2_ami                            = "${var.aws_ec2_ami}"
  aws_ec2_public_key_name                = "${var.aws_ec2_public_key_name}"
  aws_vpc_id                             = "${var.aws_vpc_id}"
  aws_vpc_private_subnet_ids             = "${var.aws_vpc_private_subnet_ids}"
  aws_efs_file_system_id                 = "${var.aws_efs_file_system_id}"
  aws_autoscaling_group_min_size         = "${var.aws_autoscaling_group_min_size}"
  aws_autoscaling_group_max_size         = "${var.aws_autoscaling_group_max_size}"
  aws_autoscaling_group_desired_capacity = "${var.aws_autoscaling_group_desired_capacity}"
}

resource "aws_security_group_rule" "antifragile-infrastructure" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = "${module.loadbalancer.aws_alb_security_group_id}"
  security_group_id        = "${module.servers.aws_launch_configuration_security_group_id}"
}

resource "aws_security_group_rule" "antifragile-infrastructure-1" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = "${module.servers.aws_launch_configuration_security_group_id}"
  security_group_id        = "${module.loadbalancer.aws_alb_security_group_id}"
}
