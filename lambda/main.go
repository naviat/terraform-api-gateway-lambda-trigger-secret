package main

import (
	"context"
	"fmt"
	"os"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/secretsmanager"
)

func HandleRequest(ctx context.Context) (string, error) {
	secretID := os.Getenv("SECRET_ID")
	if secretID == "" {
		return "", fmt.Errorf("SECRET_ID environment variable not set")
	}

	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		return "", fmt.Errorf("error loading configuration: %v", err)
	}

	client := secretsmanager.NewFromConfig(cfg)
	input := &secretsmanager.GetSecretValueInput{
		SecretId: aws.String(secretID),
	}

	result, err := client.GetSecretValue(ctx, input)
	if err != nil {
		return "", fmt.Errorf("error retrieving secret: %v", err)
	}

	return aws.ToString(result.SecretString), nil
}

func main() {
	lambda.Start(HandleRequest)
}
