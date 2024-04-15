# PoC

Terraform configuration that creates an AWS API Gateway, a Lambda function, and integrates AWS Secrets Manager to securely retrieve a secret. The Lambda function is set up to retrieve and decrypt a secret from Secrets Manager and return it to the client through the API Gateway
