import json
import pandas as pd
import boto3


def lambda_handler(event, context):
    
    s3_client = boto3.client("s3")
    bucket = 'forestcover-ml'
    key = 'data/train.csv'

    obj = s3_client.get_object(
        Bucket = bucket,
        Key = key
    )
    
    # Load the Forest CoverType dataset
    df = pd.read_csv(obj["Body"],low_memory=False)
    
    # Print the first few rows
    print(df.head())

    return {
        "statusCode": 200,
        "body": json.dumps(df.head().to_dict())
    }