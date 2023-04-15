locals {
  event_bus_name = "default" # Custom Bus 未対応のため
}

# ====================
# EventBridge (CloudWatch Event)
# ====================
resource "aws_cloudwatch_event_rule" "target" {
  name           = "${var.name}-${var.security_service}-rule"
  description    = "Config Rules Compliance Status Changes"
  event_bus_name = local.event_bus_name

  event_pattern = jsonencode({
    "source" : ["aws.config"],
    "detail-type" : ["Config Rules Compliance Change"],
    "detail" : {
      "messageType" : ["ComplianceChangeNotification"],
      "newEvaluationResult" : {
        "complianceType" : ["NON_COMPLIANT"]
      },
      #"configRuleName" : {
      #"prefix": "sample-"
      #}
    }
  })
}

resource "aws_cloudwatch_event_target" "target" {
  rule           = aws_cloudwatch_event_rule.target.name
  event_bus_name = local.event_bus_name
  target_id      = "${var.name}-${var.security_service}-to-sns"
  arn            = aws_sns_topic.target.arn
}

resource "aws_cloudwatch_event_permission" "target" {
  principal      = data.aws_caller_identity.self.account_id
  statement_id   = "${var.name}-${var.security_service}-statement"
  event_bus_name = local.event_bus_name
  action         = "events:PutEvents"
}

# ====================
# SNS
# ====================
resource "aws_sns_topic" "target" {
  name = "${var.name}-${var.security_service}-topic"
}

resource "aws_sns_topic_policy" "target" {
  arn = aws_sns_topic.target.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "SNS:Publish"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        "Resource" = "${aws_sns_topic.target.arn}"
      }
    ]
  })
}
