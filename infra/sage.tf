###############################SAGEMAKER###############################

# sagemaker IAM role for fullaccess while running notebooks
resource "aws_iam_role" "sagemaker-role" {
  name                = "sagemaker_role_tf"
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

# sagemaker IAM policy known as AmazonSageMakerFullAccess
data "aws_iam_policy" "AmzSageMakerS3Access" {
  arn                 = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Attach the policy to role (both created above)
resource "aws_iam_role_policy_attachment" "sagemaker-role-policy-attach" {
  for_each = toset([
    "${data.aws_iam_policy.AmazonSageMakerFullAccess.arn}",
    "${data.aws_iam_policy.AmzSageMakerS3Access.arn}"
  ])

  role                = "${aws_iam_role.sagemaker-role.name}"
  policy_arn          = each.value
}