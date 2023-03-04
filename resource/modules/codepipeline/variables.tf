variable "env" {}
variable "prefix" {}
variable "repository_name" {}
variable "branch_name" {}

variable "repository_id" {}
variable "clone_url_http" {}
variable "codecommit_arn" {}

data "aws_caller_identity" "self" {}
data "aws_region" "self" {}
