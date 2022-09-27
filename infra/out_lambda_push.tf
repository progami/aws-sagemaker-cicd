###############################LAMBDA###############################

# Creating Lambda IAM resource / role
resource "aws_iam_role" "lambda_iam" {
  name = "lambda_push_role_tf"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "revoke_keys_role_policy" {
  name = aws_iam_role.lambda_iam.name
  role = aws_iam_role.lambda_iam.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*",
        "ses:*",
        "sns:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# Creating Lambda resource for email service
resource "aws_lambda_function" "lambda_push" {
  function_name               = "lambda_push"
  role                        = aws_iam_role.lambda_iam.arn
  handler                     = "lambda_push.lambda_handler"
  runtime                     = "python3.9"
  timeout                     = 5
  filename                    = "src/lambda_push.zip"
  source_code_hash            = filebase64sha256("src/lambda_push.zip")
  environment {
    variables = {
      env                     = "dev"
      SENDER_EMAIL            = "jarraramjad@gmail.com"
      RECEIVER_EMAIL          = "jarraramjad@gmail.com"
      region                  = var.aws_region
      SNS_ARN                 = aws_sns_topic.topic.arn
    }
  }
}

# Adding S3 bucket as trigger to my lambda and giving the permissions
resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  bucket = aws_s3_bucket.zepto-bucket.id
  lambda_function {
    lambda_function_arn       = aws_lambda_function.lambda_push.arn
    events                    = ["s3:ObjectCreated:*"]
    filter_prefix             = "boston-housing/"
    filter_suffix             = "reports.csv"
  
  }
}
resource "aws_lambda_permission" "allowS3InvokePushLambda" {
  statement_id                = "AllowS3Invoke"
  action                      = "lambda:InvokeFunction"
  function_name               = aws_lambda_function.lambda_push.function_name
  principal                   = "s3.amazonaws.com"
  source_arn                  = "arn:aws:s3:::${aws_s3_bucket.zepto-bucket.id}"
}

###############################SNS Topic###############################

resource "aws_sns_topic" "topic" {
  name                        = "pub_sub"
}

resource "aws_sns_topic_subscription" "email-target" {
  topic_arn                   = aws_sns_topic.topic.arn
  protocol                    = "email"
  endpoint                    = "jarraramjad@gmail.com"
}

