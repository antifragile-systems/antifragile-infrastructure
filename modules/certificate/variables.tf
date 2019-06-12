variable "name" {
}

variable "domain_name" {
}

variable "subject_alternative_names" {
  type    = list(string)
  default = []
}

variable "aws_route53_zone_id" {
}

variable "aws_region" {
  default = "us-east-1"
}

