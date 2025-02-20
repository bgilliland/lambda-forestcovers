import pandas as pd
import boto3
from pydantic import BaseModel, Field, model_validator
from typing import Optional, Any

class DataLoader(BaseModel):
    client: Optional[Any] = Field(init=False)
    bucket: str
    key: str

    @model_validator(mode='before')
    def create_boto_client(cls, values):
        values["client"] = boto3.client("s3")
        return values
    
    def get_data(self):
        obj = self.client.get_object(
            Bucket = self.bucket,
            Key = self.key
        )
        return pd.read_csv(obj["Body"],low_memory=False)