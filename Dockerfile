FROM python:3.8

RUN pip3 install --no-cache scikit-learn pandas joblib flask requests boto3 tabulate sagemaker-training

COPY train.py /opt/ml/train.py
COPY serve.py /opt/ml/serve.py

RUN chmod 755 /opt/ml/train.py /opt/ml/serve.py

EXPOSE 8080

ENTRYPOINT [ "/opt/ml/train.py" ]