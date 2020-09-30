variable "name" {
  default = "antifragile-infrastructure"
}

variable "domain_name" {
}

variable "cidr_block" {
}

variable "vpn_customer_gateway_hostname" {
}

variable "vpn_customer_gateway_cidr_block" {
}

variable "vpn_customer_gateway_psk" {
}

variable "public_key" {
}

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
  default = "ami-0cf112c4c967e0437"
}

variable "sync_agent_ip_address" {
}

variable "sync_server_hostname" {
}

variable "database_master_username" {
}

variable "database_master_password" {
}

