import json
import pandas as pd
from sklearn.datasets import fetch_covtype

def lambda_handler(event, context):
    # Load the Forest CoverType dataset
    data = fetch_covtype(as_frame=True)
    
    # Convert to DataFrame
    df = data.frame
    
    # Print the first few rows
    print(df.head())

    return {
        "statusCode": 200,
        "body": json.dumps(df.head().to_dict())
    }