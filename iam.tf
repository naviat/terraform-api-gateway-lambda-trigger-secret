resource "aws_iam_role" "lambda_execution_role" {
  name = "APIGatewayLambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "SecretsManagerAccess"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = "secretsmanager:GetSecretValue"
          Resource = "*"
          Effect   = "Allow"
        },
      ]
    })
  }
}