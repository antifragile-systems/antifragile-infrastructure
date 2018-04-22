variable "name" {}

variable "aws_region" {}

variable "aws_ec2_instance_type" {}

variable "aws_ec2_ami" {}

variable "aws_ec2_public_key" {}

variable "aws_vpc_id" {}

variable "aws_vpc_subnet_ids" {
  type = "list"
}

variable "aws_efs_file_system_id" {}

variable "aws_autoscaling_group_min_size" {}

variable "aws_autoscaling_group_max_size" {}

variable "aws_autoscaling_group_desired_capacity" {}
