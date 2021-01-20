provider "aws" {
  region = "${var.region}"
  assume_role {
    role_arn     = "arn:aws:iam::${var.account}:role/deploy-role"
    session_name = "DeployTerraformRole"
    external_id  = "TerraformID"
  }
}

resource "aws_qldb_ledger" "vehicle_ledger" {
  name = "vehicle-registration"
  deletion_protection = false
}

resource "aws_iam_role" "lambda_qldb_eole" {
  name = "lambda_qldb_ole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "lambda-qldb-demo" {
 image_uri      = "${var.account}.dkr.ecr.us-east-1.amazonaws.com/lambda-container-demo-repo:qldb-latest"
 function_name = "lambda-qldb-demo"
 role          = "${aws_iam_role.lambda_qldb_eole.arn}"
 package_type  = "Image"

 tracing_config {
   mode = "Active"
 }

 depends_on    = ["aws_iam_role_policy_attachment.lambda_logs", "aws_cloudwatch_log_group.lambda_demo"]
}

# This is to optionally manage the CloudWatch Log Group for the Lambda Function.
# If skipping this resource configuration, also add "logs:CreateLogGroup" to the IAM policy below.
resource "aws_cloudwatch_log_group" "lambda_demo" {
  name              = "/aws/lambda/aws-lambda-qldb-demo"
  retention_in_days = 1
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
resource "aws_iam_policy" "lambda_qldb_permissions" {
  name = "lambda_qldb_permissions"
  path = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "qldb:CreateLedger",
        "qldb:DeleteLedger",
        "qldb:DescribeLedger",
        "qldb:ExecuteStatement",
        "qldb:GetBlock",
        "qldb:GetDigest",
        "qldb:GetRevision",
        "qldb:InsertSampleData",
        "qldb:ListLedgers",
        "qldb:SendCommand",
        "qldb:ShowCatalog",
        "qldb:UpdateLedger"
      ],
      "Resource": "${aws_qldb_ledger.vehicle_ledger.arn}",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role = "${aws_iam_role.lambda_qldb_eole.name}"
  policy_arn = "${aws_iam_policy.lambda_qldb_permissions.arn}"
}
