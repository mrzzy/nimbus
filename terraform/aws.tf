#
# Nimbus
# Terraform Deployment
# AWS Cloud
#


locals {
  aws_region           = "ap-southeast-1" # Singapore
  s3_bucket_prefix     = local.domain_slug
  s3_dev_bucket_suffix = "dev"
  s3_data_lake_suffix  = "data-lake"
  s3_bucket_suffixes   = toset([local.s3_dev_bucket_suffix, local.s3_data_lake_suffix])
}
provider "aws" {
  region = local.aws_region
}

# iam user for Nimbus CI Terraform to alter AWS infrastructure
resource "aws_iam_user" "nimbus_ci" {
  name = "mrzzy-nimbus-ci-terraform"
  lifecycle {
    prevent_destroy = true
  }
}
resource "aws_iam_user_policy_attachment" "nimbus_ci_admin" {
  user       = aws_iam_user.nimbus_ci.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  lifecycle {
    prevent_destroy = true
  }
}

# resources for ntu-sc1015 project
# iam user to identify service account for the project
resource "aws_iam_user" "ntu_sc1015" {
  name = "ntu-sc1015"
}

# S3 bucket to host data (both row & staging) for the project
resource "aws_s3_bucket" "data" {
  bucket = "ntu-sc1015-yelp"
}

data "aws_iam_policy_document" "data_policy" {
  # allow ntu_sc1015 iam user full access to data bucket
  statement {
    sid = "AllowNTUSC1015S3Data"
    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.ntu_sc1015.arn]
    }
    resources = [aws_s3_bucket.data.arn, "${aws_s3_bucket.data.arn}/*"]
    actions   = ["s3:*"]
    effect    = "Allow"
  }
  # allow public read access to bucket objects
  statement {
    sid = "AllowS3DataPublicRead"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = ["${aws_s3_bucket.data.arn}/*"]
    actions   = ["s3:GetObject"]
    effect    = "Allow"
  }
}

resource "aws_s3_bucket_policy" "yelp_dataset" {
  bucket = aws_s3_bucket.data.id
  policy = data.aws_iam_policy_document.data_policy.json
}
