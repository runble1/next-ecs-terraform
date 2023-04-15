variable "function_name" {}
variable "log_group_name" {}
variable "env" {}
variable "region" {}
variable "account" {}

variable "subnet_private_id" {}
variable "sg_id" {}

variable "aws_apigw_id" {}
variable "aws_apigw_method" {}
variable "aws_apigw_method_id" {}
variable "aws_apigw_path" {}
variable "aws_apigw_resource_id" {}

variable "slack_bot_token" {}
variable "slack_webhook_url" {}
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
      SLACK_BOT_USER_ACCESS_TOKEN = var.slack_bot_token,
      SLACK_WEBHOOK_URL           = var.slack_webhook_url
      GITHUB_API_TOKEN            = var.github_api_token
    }
  }

  vpc_config {
    subnet_ids         = [var.subnet_private_id]
    security_group_ids = [var.sg_id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_policy,
    aws_cloudwatch_log_group.lambda_log_group
  ]

  tags = {
    Name = "${var.env}-slackbot"
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
  name   = "${var.env}-AWSAlertSlackbotLambdaPolicy"
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
  name               = "${var.env}-AWSAlertSlackbotLambdaRole"
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
    Name = "${var.env}-slackbot"
  }
}

resource "aws_kms_alias" "lambda_key_alias" {
  name          = "alias/${var.function_name}"
  target_key_id = aws_kms_key.lambda_key.id
}

# ====================
#
# API Gateway Integration
#
# ====================
resource "aws_lambda_permission" "aws_apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.aws_alert_function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${var.account}:${var.aws_apigw_id}/*/${var.aws_apigw_method}${var.aws_apigw_path}"
}

resource "aws_api_gateway_integration" "aws_api" {
  rest_api_id             = var.aws_apigw_id
  resource_id             = var.aws_apigw_resource_id
  http_method             = var.aws_apigw_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY" #Lambda proxy integration
  uri                     = aws_lambda_function.aws_alert_function.invoke_arn
}

resource "aws_api_gateway_method_response" "aws_response_200" {
  rest_api_id = var.aws_apigw_id
  resource_id = var.aws_apigw_resource_id
  http_method = var.aws_apigw_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "aws_response_200" {
  rest_api_id = var.aws_apigw_id
  resource_id = var.aws_apigw_resource_id
  http_method = var.aws_apigw_method

  status_code = aws_api_gateway_method_response.aws_response_200.status_code

  response_templates = {
    "application/json" = ""
  }
  depends_on = [aws_api_gateway_integration.aws_api]
}

resource "aws_api_gateway_deployment" "aws_api" {
  rest_api_id = var.aws_apigw_id

  triggers = {
    redeployment = sha1(jsonencode([
      var.aws_apigw_id,
      var.aws_apigw_method_id,
      aws_api_gateway_integration.aws_api.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "aws_api" {
  deployment_id = aws_api_gateway_deployment.aws_api.id
  rest_api_id   = var.aws_apigw_id
  stage_name    = "v1"
  #depends_on = [aws_cloudwatch_log_group.aws_api]
}
