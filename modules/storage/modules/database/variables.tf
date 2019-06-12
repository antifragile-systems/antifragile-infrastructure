variable "name" {
}

variable "aws_vpc_id" {
}

variable "aws_database_subnet_ids" {
  type = list(string)
}

variable "database_master_username" {
}

variable "database_master_password" {
}

