variable "name" {
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

variable "aws_vpc_id" {
}

variable "aws_vpc_public_subnet_ids" {
  type = list(string)
}

variable "aws_ec2_public_key_name" {
}
