variable "name" {}

variable "aws_availability_zone_names" {
  type = "list"
}

variable "is_ascending_order" {
  default = true
}

variable "aws_vpc_id" {}

variable "aws_cidr_block" {}

variable "aws_ipv6_cidr_block" {}

variable "aws_route_table_id" {}
