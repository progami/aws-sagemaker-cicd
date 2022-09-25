
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