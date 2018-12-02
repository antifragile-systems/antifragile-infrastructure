resource "aws_iam_role" "antifragile-infrastructure" {
  name               = "${var.name}.ECSServiceRole"
  assume_role_policy = "${file("${path.module}/ecs-service-role.json")}"
}

resource "aws_iam_role_policy_attachment" "antifragile-infrastructure" {
  role       = "${aws_iam_role.antifragile-infrastructure.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}
