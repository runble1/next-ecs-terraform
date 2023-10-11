variable "env" {}
variable "service" {}

variable "vpc_id" {}
variable "subnet_private_1a_id" {}
variable "subnet_private_1c_id" {}
variable "alb_target_group_arn" {}
variable "alb_sg_id" {}

data "aws_caller_identity" "self" {}