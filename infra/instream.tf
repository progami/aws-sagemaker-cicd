###############################LAMBDA#################################

resource "aws_iam_role" "lambda_in_dynamodb_role_tf" {
  name = "lambda_in_dynamodb_tf"

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

resource "aws_iam_role_policy" "lambda_in_dynamodb_policy" {
  name = aws_iam_role.lambda_in_dynamodb_role_tf.name
  role = aws_iam_role.lambda_in_dynamodb_role_tf.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*",
        "dynamodb:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


# Creating Lambda resource for fetching data from dynmodb instream
resource "aws_lambda_function" "lambda_in_dynamodb" {
  function_name               = "lambda_in_dynamodb"
  role                        = aws_iam_role.lambda_in_dynamodb_role_tf.arn
  handler                     = "lambda_in_dynamodb.lambda_handler"
  runtime                     = "python3.9"
  timeout                     = 5
  filename                    = "src/lambda_in_dynamodb.zip"
  source_code_hash            = filebase64sha256("src/lambda_in_dynamodb.zip")

}


###############################S3 Bucket###############################

# Create an S3 Bucket for storing data files
resource "aws_s3_bucket" "zepto-bucket" {
  bucket              = "123124-zepto-s3-bucket"

  tags = {
    Name              = "zepto-bucket"
    Environment       = "Dev"
  }
  force_destroy = true
}

# create subdirectory-boston-housing
resource "aws_s3_bucket_object" "prefix" {
  bucket       = "${aws_s3_bucket.zepto-bucket.id}"
  key          = "${var.prefix}/"
  content_type = "application/x-directory"
  force_destroy = true
}

# create the output folder
resource "aws_s3_bucket_object" "output_folder" {
  bucket       = "${aws_s3_bucket.zepto-bucket.id}"
  key          = "${var.prefix}/output/"
  content_type = "application/x-directory"
  force_destroy = true
}

# create the source code directory
resource "aws_s3_bucket_object" "source_folder" {
  bucket       = "${aws_s3_bucket.zepto-bucket.id}"
  key          = "${var.prefix}/source-folders/"
  content_type = "application/x-directory"
  force_destroy = true
}

# ACL set to private access
resource "aws_s3_bucket_acl" "zepto-acl" {
  bucket              = aws_s3_bucket.zepto-bucket.id
  acl                 = "private"
}