variable "name" {}
variable "aws_sns_topic_arn" {}
variable "slack_workspace_id" {}
variable "slack_channel_id" {}

# ====================
# Chatbot
# ====================
resource "awscc_chatbot_slack_channel_configuration" "lambdas_errors" {
  configuration_name = var.name
  slack_channel_id   = var.slack_channel_id
  slack_workspace_id = var.slack_workspace_id

  iam_role_arn       = aws_iam_role.chatbot.arn
  guardrail_policies = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
  user_role_required = false

  sns_topic_arns = [var.aws_sns_topic_arn]

  logging_level = "ERROR"
}

resource "aws_iam_role" "chatbot" {
  name = "${var.name}-chatbot-role"

  assume_role_policy = <<-EOS
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "chatbot.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOS
}

resource "aws_iam_policy" "chatbot" {
  name   = "${var.name}-chatbot-policy"
  policy = file("../../modules/cloudwatch/iam_chatbot.json")
}

resource "aws_iam_role_policy_attachment" "chatbot" {
  policy_arn = aws_iam_policy.chatbot.arn
  role       = aws_iam_role.chatbot.name
}
