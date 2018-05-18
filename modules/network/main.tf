resource "aws_vpc" "antifragile-infrastructure" {
  cidr_block           = "${var.aws_cidr_block}"
  enable_dns_hostnames = true

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

data "aws_availability_zones" "available" {}

resource "aws_subnet" "antifragile-infrastructure" {
  count             = "${length(data.aws_availability_zones.available.names)}"
  vpc_id            = "${aws_vpc.antifragile-infrastructure.id}"
  cidr_block        = "${cidrsubnet(var.aws_cidr_block, 8, count.index)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  tags {
    Name = "${format("${var.name}-%d", count.index)}"
  }
}

resource "aws_route_table" "antifragile-infrastructure" {
  vpc_id = "${aws_vpc.antifragile-infrastructure.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.antifragile-infrastructure.id}"
  }

  tags {
    Name = "${var.name}"
  }
}

resource "aws_route_table_association" "antifragile-infrastructure" {
  count          = "3"
  subnet_id      = "${element(aws_subnet.antifragile-infrastructure.*.id, count.index)}"
  route_table_id = "${aws_route_table.antifragile-infrastructure.id}"
}
