import os
import io
import boto3
import json

GET_PATH  = "/dev/getsage"
POST_PATH = "/dev/results"

# grab environment variables
ENDPOINT_NAME = "boston-housing-model-2022-09-29-15-34-43-267"
runtime= boto3.client('runtime.sagemaker')

def lambda_handler(event, context):
    
    print(event["path"])
    
    if event["path"] == POST_PATH:

        event = event['queryStringParameters']
    
        data = json.loads(json.dumps(event))
        payload = data['data']
        
        print('payload:\n', payload)
                
        response = runtime.invoke_endpoint(EndpointName=ENDPOINT_NAME,
                                           Body=payload,
                                           ContentType = 'text/csv')
        
        result = json.loads(response['Body'].read().decode())
        
        result = 'Predicted Block According to Features is: ' + str(round(result))
        return {'statusCode': 200, 'body': json.dumps(result)}
    
    elif event["path"] == GET_PATH:
        return {'statusCode': 200, 'body': json.dumps(ENDPOINT_NAME)}