variable "name" {}

variable "aws_vpc_id" {}

variable "aws_cidr_block" {}

variable "aws_vpc_default_security_group_id" {}

variable "aws_vpc_subnet_ids" {
  type = "list"
}
