resource "aws_ssm_parameter" "image_name" {
  name = "/${var.service}/image_name"
  type = "String"

  # ここを自動化したい
  value = "${data.aws_caller_identity.self.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/${var.service}:e61831eb7a41d98e79b03ce3bb2ecf28ed097a59"

  # value が変更されても Terraform で差分が発生しない
  #lifecycle {
  #  ignore_changes = [value]
  #}
}

data "aws_ssm_parameter" "image_name" {
  name = "/${var.service}/image_name"
  depends_on = [
    aws_ssm_parameter.image_name
  ]
}
