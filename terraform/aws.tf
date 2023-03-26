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
# block public access on bucket
resource "aws_s3_bucket_public_access_block" "lake" {
  bucket              = aws_s3_bucket.lake.id
  block_public_acls   = true
  block_public_policy = true
}
