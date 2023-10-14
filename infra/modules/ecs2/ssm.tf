resource "aws_ssm_parameter" "image_name" {
  name = "/${var.service}/image_name"
  type = "String"

  # ここを自動化したい
  value = "${data.aws_caller_identity.self.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/nextjs:49bd98bea71dd4a6a04a23a1e8cf5e14a8ed990b"

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
