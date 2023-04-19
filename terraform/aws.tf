#
# Nimbus
# Terraform Deployment
# AWS Cloud
#

provider "aws" {
  region = "ap-southeast-1" # Singapore
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


# iam user to authenticate Airflow data pipelines
resource "aws_iam_user" "airflow" {
  name = "mrzzy-airflow-pipeline"
}
# allow CRUD on S3 objects
resource "aws_iam_user_policy_attachment" "airflow_s3" {
  user       = aws_iam_user.airflow.name
  policy_arn = aws_iam_policy.s3_crud.arn
}
# allow access to Redshift data warehouse
resource "aws_iam_user_policy_attachment" "airflow_redshift" {
  user       = aws_iam_user.airflow.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftFullAccess"
}

# iam policy to allow AWS services to assume iam role
data "aws_iam_policy_document" "assume_role" {
  for_each = toset([
    "redshift.amazonaws.com",
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
# iam role to identify redshift when accessing other AWS services (eg. S3)
resource "aws_iam_role" "warehouse" {
  name               = "warehouse"
  assume_role_policy = data.aws_iam_policy_document.assume_role["redshift.amazonaws.com"].json
}
# allow Redshift CRUD on S3 and Athena access to query S3 objects
resource "aws_iam_role_policy_attachment" "warehouse_s3" {
  for_each = toset([
    aws_iam_policy.s3_crud.arn,
    "arn:aws:iam::aws:policy/AmazonAthenaFullAccess",
  ])
  role       = aws_iam_role.warehouse.name
  policy_arn = each.key
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

# VPC
# security group to redshift serverless workgroup
resource "aws_security_group" "warehouse" {
  name        = "warehouse"
  description = "Security group attached to Redshift Serverless Workgroup warehouse."
}
# allow all egress traffic
resource "aws_vpc_security_group_egress_rule" "warehouse" {
  security_group_id = aws_security_group.warehouse.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1 # any
}
# allow redshift traffic over port 5439
resource "aws_vpc_security_group_ingress_rule" "warehouse" {
  security_group_id = aws_security_group.warehouse.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 5439
  to_port     = 5439
}

# S3
# S3 bucket for development
module "s3_dev" {
  source = "./modules/aws/s3"
  bucket = "mrzzy-co-dev"
}
# S3 bucket as a Data Lake
module "s3_lake" {
  source = "./modules/aws/s3"
  bucket = "mrzzy-co-data-lake"
}

# Glue
locals {
  s3_bucket_suffixes = toset(["dev", "data-lake"])
}
# Glue Data Catalogs for S3 buckets
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
    path = "s3://mrzzy-co-${each.key}/providence/grade=raw/"
  }
}

# Redshift Serverless Data Warehouse
# namespace to segeregate our db objects within the redshift serverless
resource "aws_redshiftserverless_namespace" "warehouse" {
  namespace_name = "main"
  db_name        = "mrzzy"
  # default iam role must also be listed in iam roles
  default_iam_role_arn = aws_iam_role.warehouse.arn
  iam_roles            = [aws_iam_role.warehouse.arn]
  lifecycle {
    ignore_changes = [
      iam_roles
    ]
  }
}
# workgroup of redshift serverless compute resources
resource "aws_redshiftserverless_workgroup" "warehouse" {
  namespace_name     = aws_redshiftserverless_namespace.warehouse.id
  workgroup_name     = "main"
  security_group_ids = [aws_security_group.warehouse.id]
  # by default, redshift serverless runs with 128 RPUs, which is overkill.
  # with our small use case the minimum of 8 RPUs should do.
  base_capacity = 8
  # public access needed for querying from GCP over the internet
  publicly_accessible = true
}
# expose tables in Glue Data Catalog crawled by Glue Crawlers in redshift as external tables
resource "aws_redshiftdata_statement" "example" {
  # mapping of redshift db to glue data catalog
  for_each = {
    # dev database is auto created for each redshift serverless namespace
    "dev"                                                   = aws_glue_catalog_database.catalog["dev"].name
    "${aws_redshiftserverless_namespace.warehouse.db_name}" = aws_glue_catalog_database.catalog["data-lake"].name
  }
  workgroup_name = aws_redshiftserverless_workgroup.warehouse.workgroup_name
  database       = each.key
  sql            = <<-EOF
    CREATE EXTERNAL SCHEMA IF NOT EXISTS lake
    FROM DATA CATALOG
    DATABASE '${each.value}'
    IAM_ROLE 'arn:aws:iam::132307318913:role/warehouse';
  EOF
  lifecycle {
    ignore_changes = [
      sql,
    ]
  }
}
