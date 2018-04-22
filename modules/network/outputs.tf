output "aws_vpc_id" {
  value = "${aws_vpc.antifragile-systems.id}"
}

output "aws_vpc_subnet_ids" {
  value = [
    "${aws_subnet.antifragile-systems.*.id}",
  ]
}
