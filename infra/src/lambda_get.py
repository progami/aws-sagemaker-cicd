import json
import boto3

s3 = boto3.client('s3')

BUCKET_NAME = "123124-zepto-s3-bucket"
FILE_NAME   = "boston-housing/reports.csv"

def lambda_handler(event, context):


    fileObj = s3.get_object(Bucket=BUCKET_NAME, Key=FILE_NAME)
    file_content = fileObj["Body"].read()
    # print
    return {
        "statusCode": 200,
        "headers": {
            "Content-type": "text/html",
            "Content-Disposition": "attachment; filename={}".format(FILE_NAME)
        },
        "body": file_content
    }
        # return {
        #     'headers': { "Content-type": "text/html" },