variable "name" {}

variable "aws_vpc_id" {}

variable "aws_vpc_public_subnet_ids" {
  type = "list"
}

variable "aws_ec2_public_key_name" {}
