variable "api_gateway_name_aws" {}
variable "env" {}

# ====================
#
# API Gateway
#
# ====================
resource "aws_api_gateway_rest_api" "aws_api" {
  name = var.api_gateway_name_aws
  endpoint_configuration {
    types = ["EDGE"]
  }
}

resource "aws_api_gateway_resource" "aws_api" {
  rest_api_id = aws_api_gateway_rest_api.aws_api.id
  parent_id   = aws_api_gateway_rest_api.aws_api.root_resource_id
  path_part   = "awsalert"
}

resource "aws_api_gateway_method" "aws_api" {
  resource_id   = aws_api_gateway_resource.aws_api.id
  rest_api_id   = aws_api_gateway_rest_api.aws_api.id
  http_method   = "POST"
  authorization = "NONE"
}

# ====================
#
# Cloudwatch Log
#
# ====================
resource "aws_cloudwatch_log_group" "aws_api" {
  name              = "/API-Gateway/${var.api_gateway_name_aws}"
  retention_in_days = 7
}
