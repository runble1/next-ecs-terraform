output "nat_gw_ip" {
  value = module.network.nat_gw_ip
}

output "api_url_for_aws" {
  description = "Slack Event Subscriptions URL"
  value       = "${module.aws_lambda.aws_api_gateway_stage_invoke_url}${module.aws_api_gateway.aws_apigw_path}"
}
