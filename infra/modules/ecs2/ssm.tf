resource "aws_ssm_parameter" "image_url" {
  name = "/${var.service}/image_url"
  type = "String"

  # ここを自動化したい
  value = "${data.aws_caller_identity.self.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/nextjs:8a517a8ba6f9e64c9021ec0b3adea2c6bca04630"

  # value が変更されても Terraform で差分が発生しない
  #lifecycle {
  #  ignore_changes = [value]
  #}
}

data "aws_ssm_parameter" "image_url" {
  name = "/${var.service}/image_url"
  depends_on = [
    aws_ssm_parameter.image_url
  ]
}
