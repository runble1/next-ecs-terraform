# ====================
# Common
# ====================
module "network" {
  source                   = "../../modules/network"
  vpc_name                 = "${var.environment}-slackbot-vpc"
  subnet_public_name       = "${var.environment}-slackbot-public-1a"
  subnet_private_name      = "${var.environment}-slackbot-private-1a"
  internet_gateway_name    = "${var.environment}-slackbot-gateway"
  elastic_ip_name          = "${var.environment}-slackbot-eip" #変更した場合ISへ申請必要
  nat_gateway_name         = "${var.env}-slackbot-nat-gw"
  route_table_public_name  = "${var.env}-slackbot-public"
  route_table_private_name = "${var.env}-slackbot-private"
  security_group_name      = "${var.env}-slackbot-sg"
}

module "chatbot" {
  depends_on         = [module.aws_cloudwatch]
  source             = "../../modules/chatbot"
  name               = "${var.env}-slackbot-error"
  aws_sns_topic_arn  = module.aws_cloudwatch.sns_topic_arn
  slack_workspace_id = var.slack_workspace_id
  slack_channel_id   = var.slack_channel_id
}

# ====================
#
# AWS
#
# ====================
module "aws_api_gateway" {
  source               = "../../modules/aws_api_gateway"
  api_gateway_name_aws = "${var.env}-slackbot_aws"
  env                  = var.env
}

module "aws_lambda" {
  depends_on = [module.aws_api_gateway]

  source         = "../../modules/aws_lambda"
  function_name  = "${var.env}-aws_alert_slackbot"
  log_group_name = "/aws/lambda/${var.env}-aws_alert_slackbot"

  env     = var.env
  region  = var.region
  account = var.account

  subnet_private_id = module.network.subnet_private_id
  sg_id             = module.network.sg_id

  aws_apigw_id          = module.aws_api_gateway.aws_apigw_id
  aws_apigw_method      = module.aws_api_gateway.aws_apigw_method
  aws_apigw_method_id   = module.aws_api_gateway.aws_apigw_method_id
  aws_apigw_path        = module.aws_api_gateway.aws_apigw_path
  aws_apigw_resource_id = module.aws_api_gateway.aws_apigw_resource_id

  slack_bot_token   = var.dev_slack_bot_token_aws
  slack_webhook_url = var.slack_webhook_url
  github_api_token  = var.github_api_token
}

module "aws_cloudwatch" {
  depends_on        = [module.aws_lambda]
  source            = "../../modules/cloudwatch"
  function_name     = "${var.env}-aws_alert_slackbot"
  log_group_name    = "/aws/lambda/${var.env}-aws_alert_slackbot"
  metric_name       = "ErrorCount"
  metric_name_space = "${var.env}-aws_alert_slackbot-error"
}
