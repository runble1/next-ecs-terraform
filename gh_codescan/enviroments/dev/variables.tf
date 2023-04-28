variable "region" {
  description = "AWSリージョン"
  default     = "ap-northeast-1"
}

variable "env" {
  description = "awsのprofile"
  default     = "dev"
}

variable "environment" {
  description = "awsのprofile"
  default     = "development"
}

variable "account" {
  description = "awsのaccount"
}

variable "dev_slack_bot_token_aws" {
  description = "Slack Bot Token for AWS Alert"
}

variable "slack_webhook_url" {
  description = "Slack Webhook URL"
}

variable "slack_workspace_id" {
  description = "slack workspace id"
}

variable "slack_channel_id_gh" {
  description = "slack channel id"
}

variable "github_api_token" {
  description = "github api token"
}
