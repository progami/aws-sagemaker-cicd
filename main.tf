terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
}


# Create ECR for hosting docker image
# 
resource "aws_ecr_repository" "demo-repository" {
  name                 = "demo-repo"
  image_tag_mutability = "IMMUTABLE"
}
# 
resource "aws_ecr_repository_policy" "demo-repo-policy" {
  repository = aws_ecr_repository.demo-repository.name
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "adds full ecr access to the demo repository",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  }
  EOF
}

# Create an S3 Bucket for storing data files

resource "aws_s3_bucket" "zepto-bucket" {
  bucket              = "123124-zepto-s3-bucket"

  tags = {
    Name              = "zepto-bucket"
    Environment       = "Dev"
  }
}

# create subdirectory- boston-housing

resource "aws_s3_bucket_object" "prefix" {
  bucket       = "${aws_s3_bucket.zepto-bucket.id}"
  key          = "${var.prefix}/"
  content_type = "application/x-directory"
}

## If you want to copy test/train to s3 from terraform

# resource "aws_s3_bucket_object" "file_upload" {
#   bucket = "${aws_s3_bucket.zepto-bucket.id}/${var.prefix}/"
#   key    = "test.csv"
#   source = "s3/test.csv"
#   etag   = "s3/my_files.zip"
# }

# ACL set to private access

resource "aws_s3_bucket_acl" "zepto-acl" {
  bucket              = aws_s3_bucket.zepto-bucket.id
  acl                 = "private"
}



# sagemaker IAM role for fullaccess while running notebooks

resource "aws_iam_role" "sagemaker-role" {
  name                = "sagemaker-role"
  assume_role_policy  = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}

# sagemaker IAM policy known as AmazonSageMakerFullAccess

data "aws_iam_policy" "AmazonSageMakerFullAccess" {
  arn                 = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

# Attach the policy to role (both created above)

resource "aws_iam_role_policy_attachment" "sagemaker-role-policy-attach" {
  role                = "${aws_iam_role.sagemaker-role.name}"
  policy_arn          = "${data.aws_iam_policy.AmazonSageMakerFullAccess.arn}"
}

# resource "aws_iam_role" "sagemaker-role" {
#   name = "sagemaker-role"

#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       },
#     ]
#   })

#   tags = {
#     tag-key = "tag-value"
#   }
# }