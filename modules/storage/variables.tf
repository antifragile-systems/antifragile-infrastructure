variable "name" {}

variable "aws_vpc_id" {}

variable "aws_cidr_block" {}

variable "aws_vpc_private_subnet_ids" {
  type = "list"
}
