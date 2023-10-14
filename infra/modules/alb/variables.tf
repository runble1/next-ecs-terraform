variable "env" {}
variable "service" {}
variable "vpc_id" {}
variable "subnet_public_1a_id" {}
variable "subnet_public_1c_id" {}
variable "lb_port" {}
variable "app_port" {}

data "aws_caller_identity" "self" {}
data "aws_elb_service_account" "main" {}