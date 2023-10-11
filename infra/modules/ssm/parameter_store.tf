resource "aws_ssm_parameter" "image_name" {
  name  = "/${var.service}/image_name"
  type  = "String"
  value = "${data.aws_caller_identity.self.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/${var.service}:e36242b84bd0bf3a28d67f69b65ebb7d43fdf528"
  #value = "404307571516.dkr.ecr.ap-northeast-1.amazonaws.com/nextjs-github:5e473ebfc263062459815a9f8a2e251868f96cf5"

  # value が変更されても Terraform で差分が発生しない
  lifecycle {
    ignore_changes = [value]
  }
}
