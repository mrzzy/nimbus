#
# Nimbus
# Terraform Deployment
# AWS Cloud
#


locals {
  aws_region           = "ap-southeast-1" # Singapore
  s3_bucket_prefix     = "mrzzy-co"
  s3_dev_bucket_suffix = "dev"
  s3_data_lake_suffix  = "data-lake"
  s3_bucket_suffixes   = toset([local.s3_dev_bucket_suffix, local.s3_data_lake_suffix])
}
provider "aws" {
  region = local.aws_region
}

# IAM
# iam policy to allows holder to list, CRUD objects in S3 buckets
data "aws_iam_policy_document" "s3_crud" {
  statement {
    sid       = "ListS3Buckets"
    resources = ["*"]
    actions   = ["s3:ListBucket"]
  }
  statement {
    sid       = "CRUDS3Objects"
    resources = ["*"]
    actions   = ["s3:*Object"]
  }
}
resource "aws_iam_policy" "s3_crud" {
  name   = "AllowCRUDS3Objects"
  policy = data.aws_iam_policy_document.s3_crud.json
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

# iam user to authenticate Providence Github Actions CI
resource "aws_iam_user" "providence_ci" {
  name = "mrzzy-providence-ci"
}
# allow full access on S3 buckets & objects
resource "aws_iam_user_policy_attachment" "providence_ci_s3" {
  user       = aws_iam_user.providence_ci.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
# allow providence CI's E2E test to create redshift schemas
resource "aws_iam_user_policy_attachment" "providence_ci_redshift" {
  user       = aws_iam_user.providence_ci.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftFullAccess"
}
resource "aws_iam_user_policy_attachment" "providence_ci_redshiftdata" {
  user       = aws_iam_user.providence_ci.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftDataFullAccess"
}

# iam policy to allow AWS services to assume iam role
data "aws_iam_policy_document" "assume_role" {
  for_each = toset([
    "glue.amazonaws.com",
  ])
  statement {
    sid     = format("Allow%sToAssumeRole", title(split(".", each.key)[0]))
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = [each.key]
    }
  }
}
# iam role to identify Glue Crawlers when accessing other AWS services
resource "aws_iam_role" "lake_crawler" {
  # by default, Glue only allows iam roles with 'AWSGlueServiceRole' prefix to attached
  name               = "AWSGlueServiceRoleCrawler"
  assume_role_policy = data.aws_iam_policy_document.assume_role["glue.amazonaws.com"].json
}
# attach managed iam policy for Glue Crawlers
resource "aws_iam_role_policy_attachment" "lake_crawler_role" {
  role       = aws_iam_role.lake_crawler.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}
# allow CRUD on S3 objects
resource "aws_iam_role_policy_attachment" "lake_crawler_s3" {
  role       = aws_iam_role.lake_crawler.name
  policy_arn = aws_iam_policy.s3_crud.arn
}

# Providence infrastructure
module "providence" {
  source = "github.com/mrzzy/providence//infra/terraform?ref=94fadbc4ddcf6fe7bd6f7abed1babb8c5d1f1b8d"

  region            = local.aws_region
  pipeline_aws_user = "mrzzy-airflow-pipeline"
  s3_dev_bucket     = "${local.s3_bucket_prefix}-${local.s3_dev_bucket_suffix}"
  s3_prod_bucket    = "${local.s3_bucket_prefix}-${local.s3_data_lake_suffix}"
  redshift_prod_db  = "mrzzy"
}

# Glue
# Glue Data Catalogs for Providence's S3 buckets
resource "aws_glue_catalog_database" "catalog" {
  for_each = local.s3_bucket_suffixes
  name     = each.key
}
# Glue Crawlers for S3 buckets
resource "aws_glue_crawler" "crawler" {
  for_each      = local.s3_bucket_suffixes
  name          = "${each.key}-crawler"
  database_name = aws_glue_catalog_database.catalog[each.key].name
  role          = aws_iam_role.lake_crawler.arn

  # crawl raw data ingested for mrzzy/providence project
  s3_target {
    path = "s3://${local.s3_bucket_prefix}-${each.key}/providence/grade=raw/"
  }
}
