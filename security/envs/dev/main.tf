locals {
  service = "nextjs-github"
}

module "config" {
  source           = "../../modules/config"
  security_service = "config-rules"
  name             = local.service
}

module "guardduty" {
  source           = "../../modules/guardduty"
  security_service = "guardduty"
  name             = local.service
}

module "inspector" {
  source           = "../../modules/inspector"
  security_service = "inspector"
  name             = local.service
}

module "iam_access_analyzer" {
  source           = "../../modules/iam_access_analyzer"
  security_service = "iam_access_analyzer"
  name             = local.service
}

module "securityhub" {
  source           = "../../modules/securityhub"
  security_service = "securityhub"
  name             = local.service
}

module "chatbot" {
  source                          = "../../modules/chatbot"
  name                            = local.service
  slack_workspace_id              = var.slack_workspace_id
  slack_channel_id                = var.slack_channel_id
  sns_topic_configrules_arn       = module.config.sns_topic_configrules_arn
  sns_topic_guardduty_arn         = module.guardduty.sns_topic_guardduty_arn
  sns_topic_inspector_arn         = module.inspector.sns_topic_inspector_arn
  sns_topic_iamaccessanalyzer_arn = module.iam_access_analyzer.sns_topic_iamaccessanalyzer_arn
}
