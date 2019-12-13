variable "name" {
}

variable "aws_vpc_id" {
}

variable "aws_vpc_public_subnet_ids" {
  type = list(string)
}

variable "aws_ec2_nat_instance_type" {
  default = "t3a.nano"
}

variable "aws_ec2_nat_ami" {
  default = "ami-024107e3e3217a248"
}

variable "aws_ec2_public_key_name" {
}

