
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
  filename                    = "src.zip"
  source_code_hash            = filebase64sha256("src.zip")
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

# Creating Lambda resource for get function - API Gateway
resource "aws_lambda_function" "lambda_get" {
  function_name               = "lambda_get"
  role                        = aws_iam_role.lambda_iam.arn
  handler                     = "lambda_get.lambda_handler"
  runtime                     = "python3.9"
  timeout                     = 5
  filename                    = "src.zip"
  source_code_hash            = filebase64sha256("src.zip")
}

# Adding S3 bucket as trigger to my lambda and giving the permissions
resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  bucket = aws_s3_bucket.zepto-bucket.id
  lambda_function {
    lambda_function_arn       = aws_lambda_function.lambda_push.arn
    events                    = ["s3:ObjectCreated:*"]
    filter_prefix             = "boston-housing/"
    filter_suffix             = ".csv"
  
  }
}
resource "aws_lambda_permission" "test" {
  statement_id                = "AllowS3Invoke"
  action                      = "lambda:InvokeFunction"
  function_name               = aws_lambda_function.lambda_push.function_name
  principal                   = "s3.amazonaws.com"
  source_arn                  = "arn:aws:s3:::${aws_s3_bucket.zepto-bucket.id}"
}

###############################SNS Topic###############################

resource "aws_sns_topic" "topic" {
  name                        = "email_service"
}

resource "aws_sns_topic_subscription" "email-target" {
  topic_arn                   = aws_sns_topic.topic.arn
  protocol                    = "email"
  endpoint                    = "jarraramjad@gmail.com"
}

###############################API GATEWAY###############################

resource "aws_apigatewayv2_api" "lambda_get_api" {
  name                        = "v2_http_api"
  protocol_type               = "HTTP"

}

resource "aws_apigatewayv2_stage" "lambda_get_dev" {
  api_id                      = aws_apigatewayv2_api.lambda_get_api.id
  name                        = "$default"
  auto_deploy = true

    access_log_settings {
    destination_arn           = aws_cloudwatch_log_group.api_gw_logs.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

# Cloudwatch log group for storing above logs

resource "aws_cloudwatch_log_group" "api_gw_logs" {
  name                          = "/aws/api_gw/${aws_apigatewayv2_api.lambda_get_api.name}"

  retention_in_days             = 30
}

resource "aws_apigatewayv2_integration" "lambda_get_integ" {
  api_id = aws_apigatewayv2_api.lambda_get_api.id

  integration_type              = "AWS_PROXY"
  integration_method            = "POST"
  integration_uri               = aws_lambda_function.lambda_get.invoke_arn
}

resource "aws_apigatewayv2_route" "get_reports_from_s3" {
  api_id                        = aws_apigatewayv2_api.lambda_get_api.id

  route_key                     = "GET /results"
  target                        = "integrations/${aws_apigatewayv2_integration.lambda_get_integ.id}"

}

resource "aws_lambda_permission" "api_gw" {
  statement_id                  = "AllowExecutionFromAPIGateway"
  action                        = "lambda:InvokeFunction"
  function_name                 = aws_lambda_function.lambda_get.function_name
  principal                     = "apigateway.amazonaws.com"

  source_arn                    = "${aws_apigatewayv2_api.lambda_get_api.execution_arn}/*/*"
}

output "get_base_url" {
  value                         = aws_apigatewayv2_stage.lambda_get_dev.invoke_url
}