variable "name" {}
variable "slack_workspace_id" {}
variable "slack_channel_id" {}

variable "sns_topic_securityhub_arn" {}
variable "sns_topic_guardduty_arn" {}
variable "sns_topic_inspector_arn" {}
variable "sns_topic_iamaccessanalyzer_arn" {}

data "aws_caller_identity" "self" {}
