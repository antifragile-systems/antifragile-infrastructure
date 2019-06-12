resource "aws_subnet" "antifragile-infrastructure" {
  count  = length(var.aws_availability_zone_names)
  vpc_id = var.aws_vpc_id
  cidr_block = cidrsubnet(
    var.aws_cidr_block,
    8,
    var.is_ascending_order ? count.index : 255 - count.index,
  )
  assign_ipv6_address_on_creation = true
  ipv6_cidr_block = cidrsubnet(
    var.aws_ipv6_cidr_block,
    8,
    var.is_ascending_order ? count.index : 255 - count.index,
  )
  availability_zone = var.aws_availability_zone_names[count.index]

  tags = {
    Name            = var.name
    IsPrivateSubnet = var.is_ascending_order
  }
}

resource "aws_route_table_association" "antifragile-infrastructure" {
  count          = "3"
  subnet_id      = element(aws_subnet.antifragile-infrastructure.*.id, count.index)
  route_table_id = var.aws_route_table_id
}

