variable "name" {
  default = "antifragile-infrastructure"
}

variable "domain_name" {}

variable "cidr_block" {}

variable "vpn_customer_gateway_hostname" {}

variable "vpn_customer_gateway_psk" {}

variable "public_key" {}

variable "cluster_min_size" {
  default = "1"
}

variable "cluster_max_size" {
  default = "3"
}

variable "cluster_desired_capacity" {
  default = "3"
}

variable "aws_region" {
  default = "eu-west-1"
}

variable "aws_ec2_instance_type" {
  default = "t3.micro"
}

variable "aws_ec2_ami" {
  default = "ami-0b8e62ddc09226d0a"
}

variable "sync_agent_ip_address" {}

variable "sync_server_hostname" {}
