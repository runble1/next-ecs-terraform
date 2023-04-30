# ====================
# Common
# ====================
/*
module "chatbot" {
  depends_on         = [module.aws_cloudwatch]
  source             = "../../modules/chatbot"
  name               = "${var.env}-slackbot-error"
  aws_sns_topic_arn  = module.aws_cloudwatch.sns_topic_arn
  slack_workspace_id = var.slack_workspace_id
  slack_channel_id   = var.slack_channel_id_gh
}*/

module "lambda" {
  source         = "../../modules/lambda"
  function_name  = "${var.env}-github-app2"
  log_group_name = "/aws/lambda/${var.env}-github-app2"

  env     = var.env
  region  = var.region
  account = var.account

  slack_channel_id = var.slack_channel_id_gh
  slack_bot_token   = var.dev_slack_bot_token_aws
  github_api_token  = var.github_api_token
}

module "aws_cloudwatch" {
  depends_on        = [module.lambda]
  source            = "../../modules/cloudwatch"
  function_name     = "${var.env}-github-app2"
  log_group_name    = "/aws/lambda/${var.env}-github-app2"
  metric_name       = "ErrorCount"
  metric_name_space = "${var.env}-github-app2"
}
