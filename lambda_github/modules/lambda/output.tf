output "function_url" {
  description = "Slack Event Subscriptions URL"
  value       = aws_lambda_function_url.aws_alert_function.function_url
}
