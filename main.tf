provider "aws" {
  region = "us-east-2"
}

# resource "aws_lambda_function" "se_lambda" {
#   function_name = "APIGateway_Lambda_Function_${var.env}"
#   role          = aws_iam_role.lambda_execution_role.arn

#   handler = "main"
#   runtime = "go1.x"

#   filename         = "lambda_function_payload.zip"
#   source_code_hash = filebase64sha256("${path.module}/lambda/function.zip")

#   environment {
#     variables = {
#       SECRET_ID = var.secretID
#     }
#   }
# }

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda.py"
  output_path = "${path.module}/lambda/function.zip"
}

resource "aws_lambda_function" "se_lambda" {
  function_name    = "APIGateway_Lambda_Function_${var.env}"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.lambda.output_path
  source_code_hash = filebase64sha256(data.archive_file.lambda.output_path)

  environment {
    variables = {
      SECRET_ID = var.secretID
    }
  }
}


resource "aws_api_gateway_rest_api" "se_api" {
  name = "APILambdaV1-${var.env}"
}

resource "aws_api_gateway_resource" "se_resource" {
  rest_api_id = aws_api_gateway_rest_api.se_api.id
  parent_id   = aws_api_gateway_rest_api.se_api.root_resource_id
  path_part   = "getsecret"
}

resource "aws_api_gateway_method" "se_method" {
  rest_api_id   = aws_api_gateway_rest_api.se_api.id
  resource_id   = aws_api_gateway_resource.se_resource.id
  http_method   = "GET"
  authorization = "NONE"
  request_parameters = {
    "method.request.header.x-api-key" = true
  }
  api_key_required = true
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.se_api.id
  resource_id = aws_api_gateway_resource.se_resource.id
  http_method = aws_api_gateway_method.se_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.se_lambda.invoke_arn
}

resource "aws_lambda_permission" "allow_apigateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.se_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.se_api.execution_arn}/*/*/getsecret"
}

resource "aws_api_gateway_api_key" "se_api_key" {
  name = "SEApiKey"
}

resource "aws_api_gateway_usage_plan" "se_usage_plan" {
  name = "SEUsagePlan"

  api_stages {
    api_id = aws_api_gateway_rest_api.se_api.id
    stage  = aws_api_gateway_stage.se_stage.stage_name
  }
  depends_on = [
    aws_api_gateway_stage.se_stage
  ]
}

resource "aws_api_gateway_usage_plan_key" "se_usage_plan_key" {
  key_id        = aws_api_gateway_api_key.se_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.se_usage_plan.id
}

# Deployment to Dev
resource "aws_api_gateway_deployment" "dev_deployment" {
  rest_api_id = aws_api_gateway_rest_api.se_api.id
  stage_name  = var.env

  depends_on = [
    aws_api_gateway_integration.lambda_integration
  ]
}


resource "aws_api_gateway_stage" "se_stage" {
  deployment_id = aws_api_gateway_deployment.se_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.se_api.id
  stage_name    = var.env
}
