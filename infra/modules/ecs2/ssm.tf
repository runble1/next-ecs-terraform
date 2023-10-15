resource "aws_ssm_parameter" "image_url" {
  name = "/${var.service}/image_url"
  type = "String"

  # ここを自動化したい
  value = "${data.aws_caller_identity.self.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/nextjs:c8b85eddb72faa505434e1855e89da06893f3ac2"

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
