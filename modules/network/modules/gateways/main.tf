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
