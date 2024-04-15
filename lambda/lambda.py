import os
import json
import boto3
from botocore.exceptions import ClientError

def lambda_handler(event, context):
    secret_id = os.environ.get('SECRET_ID')
    if not secret_id:
        return {
            'statusCode': 400,
            'body': json.dumps('SECRET_ID environment variable not set')
        }

    client = boto3.client('secretsmanager')

    try:
        response = client.get_secret_value(SecretId=secret_id)
        secret = response['SecretString']
        return {
            'statusCode': 200,
            'body': json.dumps(secret)
        }
    except ClientError as e:
        return {
            'statusCode': 500,
            'body': json.dumps(str(e))
        }

