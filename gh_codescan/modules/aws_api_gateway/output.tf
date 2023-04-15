output "aws_apigw_id" {
  value = aws_api_gateway_rest_api.aws_api.id
}

output "aws_apigw_method" {
  value = aws_api_gateway_method.aws_api.http_method
}

output "aws_apigw_method_id" {
  value = aws_api_gateway_method.aws_api.id
}

output "aws_apigw_path" {
  value = aws_api_gateway_resource.aws_api.path
}

output "aws_apigw_resource_id" {
  value = aws_api_gateway_resource.aws_api.id
}