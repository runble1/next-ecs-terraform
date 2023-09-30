output "sns_topic_arn" {
  description = "Slack Event Subscriptions URL"
  value       = aws_sns_topic.lambdas_errors.arn
}
