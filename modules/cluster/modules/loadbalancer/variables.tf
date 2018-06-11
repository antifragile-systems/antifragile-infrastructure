variable "name" {}

variable "domain_name" {}

variable "aws_vpc_id" {}

variable "aws_vpc_subnet_ids" {
  type = "list"
}

variable "aws_region" {}
