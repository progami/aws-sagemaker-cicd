#!/usr/bin/env python

import os

from sagemaker.estimator import Estimator
import pandas as pd
import boto3
import botocore

# Replace with your desired configuration
initial_instance_count = 1
endpoint_instance_type = 'ml.m5.large'

BUCKET_NAME = os.environ['BUCKET_NAME']
PREFIX = os.environ['PREFIX']
OBJECT_KEY = f'{PREFIX}/reports.csv'

s3 = boto3.resource('s3')

try:
       s3.Bucket(BUCKET_NAME).download_file(OBJECT_KEY, 'reports.csv')

       # Load reports df
       reports_df = pd.read_csv('reports.csv')
       print(reports_df)

except botocore.exceptions.ClientError as e:
       if e.response['Error']['Code'] == '404':
              print("Report.csv not found!")
       else:
              raise

reports_df['date_time'] = pd.to_datetime(reports_df['date_time'], format='%Y-%m-%d %H:%M:%S')
latest_training_job_name = reports_df.sort_values(['date_time'], ascending=False).training_job_name.values[0]
attached_estimator = Estimator.attach(latest_training_job_name)



attached_predictor = attached_estimator.deploy(initial_instance_count=initial_instance_count,
                                               instance_type=endpoint_instance_type,
                                               endpoint_name=latest_training_job_name,
                                               tags=[{"Key": "email",
                                                      "Value": "jarraramjad@gmail.com"}],
                                               wait=False)
print(attached_predictor.endpoint_name)

attached_predictor.predict([[22, 5.86, 0, 0.431, 6.487, 13, 7.3967, 7, 330, 19.1, 396.28, 5.9, 24.4]])