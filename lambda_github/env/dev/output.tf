output "function_url" {
  description = "Slack Event Subscriptions URL"
  value       = "${module.lambda.function_url}"
}
