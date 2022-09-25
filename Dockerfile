FROM python:3.9

RUN pip3 install --no-cache scikit-learn pandas joblib flask requests boto3 tabulate

COPY train.py /usr/bin/train
COPY serve.py /usr/bin/serve

RUN chmod 755 /usr/bin/train /usr/bin/serve

EXPOSE 8080
