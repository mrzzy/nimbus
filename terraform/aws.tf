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
# allow CRUD on S3 objects
resource "aws_iam_user_policy_attachment" "providence_ci_s3" {
  user       = aws_iam_user.providence_ci.name
  policy_arn = aws_iam_policy.s3_crud.arn
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
resource "aws_iam_role_policy_attachment" "lake_crawler_s3" {
  role       = aws_iam_role.lake_crawler.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
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
