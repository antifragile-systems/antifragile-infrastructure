variable "name" {}

variable "domain_name" {}

variable "subject_alternative_names" {
  type    = "list"
  default = [ ]
}

variable "aws_route53_zone_id" {}

variable "aws_region" {
  default = "us-east-1"
}
