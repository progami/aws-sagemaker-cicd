import csv
import boto3
import json
from pprint import pprint


def lambda_handler(event, context):

    TABLE_NAME = event['TABLE_NAME']
    OUTPUT_BUCKET = event['OUTPUT_BUCKET']
    OUTPUT_KEY = event['OUTPUT_KEY']

    code = ingest_to_s3(TABLE_NAME, OUTPUT_BUCKET, OUTPUT_KEY)
    
    return {
    'statusCode': code,
    }


def ingest_to_s3(TABLE_NAME, OUTPUT_BUCKET, OUTPUT_KEY):

    TEMP_FILENAME = '/tmp/employees.csv'

    s3_resource = boto3.resource('s3')
    dynamodb_resource = boto3.resource('dynamodb')
    table = dynamodb_resource.Table(TABLE_NAME)
    
    
    with open(TEMP_FILENAME, 'w') as output_file:
        writer = csv.writer(output_file)
        header = True
        first_page = True

        # Paginate results
        while True:

            # Scan DynamoDB table
            if first_page:
                response = table.scan()
                first_page = False
            else:
                response = table.scan(ExclusiveStartKey = response['LastEvaluatedKey'])

            for count, item in enumerate(response['Items']):
                
                # add label column again
                item = {k: v for k, v in ([('label', count)] + list(item.items()))}
                # Write header row?
                
                if header:
                    
                    writer.writerow(item.keys())
                    header = False

                writer.writerow(item.values())

            # Last page?
            if 'LastEvaluatedKey' not in response:
                break

    # Upload temp file to S3
    s3_resource.Bucket(OUTPUT_BUCKET).upload_file(TEMP_FILENAME, OUTPUT_KEY)

    return 1
