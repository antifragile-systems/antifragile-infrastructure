resource "aws_internet_gateway" "antifragile-infrastructure" {
  vpc_id = "${var.aws_vpc_id}"

  tags {
    Name = "${var.name}"
  }
}

resource "aws_egress_only_internet_gateway" "antifragile-infrastructure" {
  vpc_id = "${var.aws_vpc_id}"
}

module "nat" {
  source                    = "./modules/nat"

  name                      = "${var.name}"
  aws_vpc_id                = "${var.aws_vpc_id}"
  aws_vpc_public_subnet_ids = "${var.aws_vpc_public_subnet_ids}"
  aws_ec2_public_key_name   = "${var.aws_ec2_public_key_name}"
}

module "vpn" {
  source                        = "./modules/vpn"

  name                          = "${var.name}"
  domain_name                   = "${var.domain_name}"
  cidr_block                    = "${var.cidr_block}"
  vpn_customer_gateway_hostname = "${var.vpn_customer_gateway_hostname}"
  vpn_customer_gateway_psk      = "${var.vpn_customer_gateway_psk}"
  aws_vpc_id                    = "${var.aws_vpc_id}"
  aws_vpc_public_subnet_ids     = "${var.aws_vpc_public_subnet_ids}"
  aws_ec2_public_key_name       = "${var.aws_ec2_public_key_name}"
}
