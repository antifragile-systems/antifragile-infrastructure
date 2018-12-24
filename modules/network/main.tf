resource "aws_vpc" "antifragile-infrastructure" {
  cidr_block                       = "${var.aws_cidr_block}"
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames             = true

  tags {
    Name = "${var.name}"
  }
}

resource "aws_internet_gateway" "antifragile-infrastructure" {
  vpc_id = "${aws_vpc.antifragile-infrastructure.id}"

  tags {
    Name = "${var.name}"
  }
}

resource "aws_egress_only_internet_gateway" "antifragile-infrastructure" {
  vpc_id = "${aws_vpc.antifragile-infrastructure.id}"
}

resource "aws_route_table" "antifragile-infrastructure-0" {
  vpc_id = "${aws_vpc.antifragile-infrastructure.id}"

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = "${module.nat.aws_nat_instance_id}"
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = "${aws_egress_only_internet_gateway.antifragile-infrastructure.id}"
  }

  tags {
    Name = "${var.name}"
  }
}

resource "aws_route_table" "antifragile-infrastructure-1" {
  vpc_id = "${aws_vpc.antifragile-infrastructure.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.antifragile-infrastructure.id}"
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = "${aws_egress_only_internet_gateway.antifragile-infrastructure.id}"
  }

  tags {
    Name = "${var.name}"
  }
}

data "aws_availability_zones" "available" {}

module "public_subnets" {
  source                      = "./modules/subnets"

  name                        = "${var.name}"
  is_ascending_order          = false
  aws_vpc_id                  = "${aws_vpc.antifragile-infrastructure.id}"
  aws_cidr_block              = "${var.aws_cidr_block}"
  aws_ipv6_cidr_block         = "${aws_vpc.antifragile-infrastructure.ipv6_cidr_block}"
  aws_route_table_id          = "${aws_route_table.antifragile-infrastructure-1.id}"
  aws_availability_zone_names = "${data.aws_availability_zones.available.names}"
}

module "nat" {
  source                    = "./modules/nat"

  name                      = "${var.name}"
  aws_vpc_id                = "${aws_vpc.antifragile-infrastructure.id}"
  aws_vpc_public_subnet_ids = "${module.public_subnets.aws_vpc_subnet_ids}"
  aws_ec2_public_key_name   = "${var.aws_ec2_public_key_name}"
}

module "private_subnets" {
  source                      = "./modules/subnets"

  name                        = "${var.name}"
  aws_vpc_id                  = "${aws_vpc.antifragile-infrastructure.id}"
  aws_cidr_block              = "${var.aws_cidr_block}"
  aws_ipv6_cidr_block         = "${aws_vpc.antifragile-infrastructure.ipv6_cidr_block}"
  aws_route_table_id          = "${aws_route_table.antifragile-infrastructure-0.id}"
  aws_availability_zone_names = "${data.aws_availability_zones.available.names}"
}
