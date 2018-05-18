output "aws_vpc_id" {
  value = "${aws_vpc.antifragile-infrastructure.id}"
}

output "aws_vpc_subnet_ids" {
  value = [
    "${aws_subnet.antifragile-infrastructure.*.id}",
  ]
}
