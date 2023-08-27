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
