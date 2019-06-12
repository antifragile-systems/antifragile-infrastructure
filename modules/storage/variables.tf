variable "name" {
}

variable "aws_vpc_id" {
}

variable "aws_cidr_block" {
}

variable "aws_vpc_private_subnet_ids" {
  type = list(string)
}

variable "aws_cloudwatch_log_group_arn" {
}

variable "sync_agent_ip_address" {
}

variable "sync_server_hostname" {
}

variable "database_master_username" {
}

variable "database_master_password" {
}

