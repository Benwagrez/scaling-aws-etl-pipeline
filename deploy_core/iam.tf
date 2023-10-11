# ========================= #
# ===== IAM resources ===== #
# ========================= #
# Purpose
# Deploying IAM resources to allow Lambda to execute actions on an S3 bucket and Athena

# Reference iam policy for sts:AssumeRole to attach to Lambda IAM role
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# Create IAM role for Lambda funtion
resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Created S3 & Athena access Policy for IAM Role
resource "aws_iam_policy" "policy" {
  name = "LambdaS3AccessPolicy"
  description = "Access policy granting Lambda access to S3 bucket where data will go through the ETL process."

  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"logs:*"
			],
			"Resource": "arn:aws:logs:*:*:*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"s3:PutObject",
				"s3:GetObject",
				"s3:ListObjects",
				"s3:ListBucket",
				"s3:ListAllMyBuckets",
				"s3:GetObjectAttributes"
			],
			"Resource": [ "arn:aws:s3:::${var.DataOutputBucketName}/*", "arn:aws:s3:::${var.DataOutputBucketName}", "arn:aws:s3:::${var.DataInputBucketName}/*", "arn:aws:s3:::${var.DataInputBucketName}" ]
		},
		{
			"Effect": "Allow",
			"Action": [
				"s3:GetBucketLocation"
			],
			"Resource": "arn:aws:s3:::*"
		}
	]
} 
	EOF
}

# Attaching iam role to lambda action policy
resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.policy.arn}"
}