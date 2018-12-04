resource "aws_service_discovery_private_dns_namespace" "antifragile-infrastructure" {
  name = "${var.domain_name}.local"
  vpc  = "${var.aws_vpc_id}"
}

resource "aws_iam_role" "antifragile-infrastructure" {
  name               = "${var.name}.ECSServiceRole"
  assume_role_policy = "${file("${path.module}/ecs-service-role.json")}"
}

resource "aws_iam_role_policy_attachment" "antifragile-infrastructure-1" {
  role       = "${aws_iam_role.antifragile-infrastructure.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_iam_role_policy_attachment" "antifragile-infrastructure-2" {
  role       = "${aws_iam_role.antifragile-infrastructure.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53AutoNamingRegistrantAccess"
}
