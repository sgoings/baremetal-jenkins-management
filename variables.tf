variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_key_path" {}
variable "aws_key_name" {}

variable "aws_ubuntu_ami" {
  default = "ami-d05e75b8"
}

variable "domain" {
  default = "goings.space"
}

variable "route53_zone_id" {
  default = "Z2JMEZGKYKLVQ4"
}
