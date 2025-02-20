import json
from src.processor import DataLoader
def lambda_handler(event, context):
    
    bucket = 'forestcover-ml'
    key = 'data/train.csv'
    loader = DataLoader(bucket=bucket,key=key)
    df = loader.get_data()
    
    # Print the first few rows
    print(df.head())

    return {
        "statusCode": 200,
        "body": json.dumps(df.head().to_dict())
    }