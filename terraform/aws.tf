#
# Nimbus
# AWS Cloud Deployment
#

provider "aws" {
  region = "ap-southeast-1" # Singapore
}

# S3 bucket as a Data Lake
resource "aws_s3_bucket" "lake" {
  bucket = "mrzzy-co-data-lake"
}
# disable S3 ACLs & grant bucket owner ownership of objects as well
resource "aws_s3_bucket_ownership_controls" "lake" {
  bucket = aws_s3_bucket.lake.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Redshift Serverless Data Warehouse
# iam policy to that allows read access to data lake
data "aws_iam_policy_document" "allow_lake" {
  statement {
    sid = "AllowS3ReadOnlyOnLake"
    resources = [
      aws_s3_bucket.lake.arn
    ]
    # derived from predefined policy "AmazonS3ReadOnlyAccess"
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3-object-lambda:Get*",
      "s3-object-lambda:List*",
    ]
  }
}
# iam policy to allow redshift to assume warehouse iam role
data "aws_iam_policy_document" "redshift_assume_role" {
  statement {
    sid     = "AllowRedshiftToAssumeRole"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["redshift.amazonaws.com"]
    }
  }
}
# role to identify redshift when accessing other AWS services (eg. S3)
resource "aws_iam_role" "warehouse" {
  name = "warehouse"
  # iam policy determining which principals can hold the role
  assume_role_policy = data.aws_iam_policy_document.redshift_assume_role.json
  # attach iam policy to applying to principals that hold the role
  inline_policy {
    name   = "allow-lake-access"
    policy = data.aws_iam_policy_document.allow_lake.json
  }
}
# namespace to segeregate our db objects within the redshift serverless
resource "aws_redshiftserverless_namespace" "warehouse" {
  namespace_name = "main"
  db_name        = "mrzzy"
  # default iam role must also be listed in iam roles
  default_iam_role_arn = aws_iam_role.warehouse.arn
  iam_roles            = [aws_iam_role.warehouse.arn]
}
# workgroup of redshift serverless compute resources
resource "aws_redshiftserverless_workgroup" "warehouse" {
  namespace_name = aws_redshiftserverless_namespace.warehouse.id
  workgroup_name = "main"
  # by default, redshift serverless runs with 128 RPUs, which is overkill.
  # with our small use case the minimum of 8 RPUs should do.
  base_capacity = 8
  # public access needed for querying from GCP over the internet
  publicly_accessible = true
}
