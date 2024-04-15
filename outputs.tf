output "api_invoke_url" {
  value = "${aws_api_gateway_rest_api.se_api.execution_arn}/getsecret"
}

output "api_key" {
  value     = aws_api_gateway_api_key.se_api_key.value
  sensitive = true
}
