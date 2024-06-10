#
# Nimbus
# Terraform Deployment
# AWS Cloud
#


locals {
  aws_region = "ap-southeast-1" # Singapore
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
