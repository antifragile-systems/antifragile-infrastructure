variable "name" {
  default = "antifragile-infrastructure"
}

variable "cidr_block" {}

variable "public_key" {}

variable "cluster_min_size" {
  default = "1"
}

variable "cluster_max_size" {
  default = "3"
}

variable "cluster_desired_capacity" {
  default = "2"
}

variable "aws_region" {}

variable "aws_ec2_instance_type" {
  default = "t2.micro"
}

variable "aws_ec2_ami" {
  default = "ami-2d386654"
}
