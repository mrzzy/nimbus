#
# Nimbus
# Terraform Deployment
# Backblaze B2 Cloud Storage
#

# Backblaze B2 Cloud Storage provider
provider "b2" {}
# off-site backup location for pickle (laptop)
resource "b2_bucket" "backup_pickle" {
  bucket_name = "${local.domain_slug}-backup-pickle"
  bucket_type = "allPrivate"

  default_server_side_encryption {
    algorithm = "AES256"
    mode      = "SSE-B2"
  }

  lifecycle_rules {
    # apply to all files
    file_name_prefix             = ""
    days_from_hiding_to_deleting = 1
  }
}

# Data Lake: raw and staging data
# used by mrzzy/providence project
resource "b2_bucket" "data_lake" {
  bucket_name = "${local.domain_slug}-data-lake"
  bucket_type = "allPrivate"

  default_server_side_encryption {
    algorithm = "AES256"
    mode      = "SSE-B2"
  }

  lifecycle_rules {
    # apply to all files
    file_name_prefix             = ""
    days_from_hiding_to_deleting = 1
  }
}

# mrzzy.co static site files
# used by mrzzy/mrzzy.co project
resource "b2_bucket" "art_mrzzy_co" {
  bucket_name = "art-${local.domain_slug}-site"
  bucket_type = "allPublic"

  lifecycle_rules {
    # apply to all files
    file_name_prefix             = ""
    days_from_hiding_to_deleting = 1
  }
}
