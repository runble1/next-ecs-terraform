variable "env" {}
variable "prefix" {}
variable "repository_name" {}
variable "branch_name" {}
data "aws_caller_identity" "self" {}
data "aws_region" "self" {}