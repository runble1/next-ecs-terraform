variable "function_name" {}
variable "log_group_name" {}
variable "env" {}
variable "region" {}
variable "account" {}

variable "slack_channel_id" {}
variable "slack_bot_token" {}
variable "github_api_token" {}

# ====================
# Archive
# ====================
data "archive_file" "function_source" {
  type        = "zip"
  source_dir  = "../../app"
  output_path = "../../archive/aws_${var.env}/aws_alert_slackbot.zip"
}

# ====================
#
# Lambda
#
# ====================
resource "aws_lambda_function" "aws_alert_function" {
  function_name = var.function_name
  handler       = "lambda.lambda_handler"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.8"
  timeout       = 10
  kms_key_arn   = aws_kms_key.lambda_key.arn

  filename         = data.archive_file.function_source.output_path
  source_code_hash = data.archive_file.function_source.output_base64sha256

  environment {
    variables = {
      SLACK_CHANNEL_ID            = var.slack_channel_id
      SLACK_BOT_USER_ACCESS_TOKEN = var.slack_bot_token,
      GITHUB_API_TOKEN            = var.github_api_token
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_policy,
    aws_cloudwatch_log_group.lambda_log_group
  ]

  tags = {
    Name = "${var.env}-githubapps"
  }
}

# ====================
# CloudWatch Log
# ====================
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = var.log_group_name
  retention_in_days = 30
}

# ====================
# IAM
# ====================
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "lambda_basic_execution" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "lambda_policy" {
  source_json = data.aws_iam_policy.lambda_basic_execution.policy

  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "${var.env}-AWSAlertSlackbotLambdaPolicy2"
  policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_policy_for_VPC" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_policy_for_APIGateway" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess"
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.env}-AWSAlertSlackbotLambdaRole2"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# ====================
#
# KMS
#
# ====================
resource "aws_kms_key" "lambda_key" {
  description             = "My Lambda Function Customer Master Key"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  tags = {
    Name = "${var.env}-githubapp2"
  }
}

resource "aws_kms_alias" "lambda_key_alias" {
  name          = "alias/${var.function_name}2"
  target_key_id = aws_kms_key.lambda_key.id
}

# ====================
# Functional URLs
# ====================
resource "aws_lambda_function_url" "aws_alert_function" {
  function_name      = aws_lambda_function.aws_alert_function.function_name
  authorization_type = "NONE"
}