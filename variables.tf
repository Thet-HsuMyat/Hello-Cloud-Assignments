variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "key_name" {
  type    = string
  default = "hsu-master"
}

variable "dashboard_ami_id" {
  type = string
}

variable "counting_ami_id" {
  type = string
}

variable "aws_profile" {
  type = string
}