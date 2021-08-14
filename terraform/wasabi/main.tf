#
# nimbus
# terraform deploy for wasabi storage
#

## Providers ##
terraform {
  backend "remote" {
    organization = "mrzzy-co"
    workspaces {
      name = "nimbus-terraform-wasabi"
    }
  }
  required_providers {
    wasabi = {
      source  = "k-t-corp/wasabi"
      version = "4.1.1"
    }
  }
  required_version = ">=1.0.1, <1.1.0"
}

provider "wasabi" {
  alias  = "eu-central-1"
  region = "eu-central-1"

  endpoints {
    sts = "https://sts.wasabisys.com"
    iam = "https://iam.wasabisys.com"
    s3  = "https://s3.eu-central-1.wasabisys.com"
  }

  access_key = var.access_key
  secret_key = var.secret_key
}

provider "wasabi" {
  alias  = "us-east-1"
  region = "us-east-1"

  endpoints {
    sts = "https://sts.wasabisys.com"
    iam = "https://iam.wasabisys.com"
    s3  = "https://s3.wasabisys.com"
  }

  access_key = var.access_key
  secret_key = var.secret_key
}


## Tiddlywiki Archive
# bucket archiving snapshots of tiddlers from the Tiddlywiki deployment
resource "wasabi_bucket" "tiddlywiki_archive" {
  provider = wasabi.eu-central-1

  bucket = "mrzzy-co-tiddlywiki-archive"
  acl    = "public-read"

  versioning {
    enabled = true
  }
}

# service account & access key for writing to tiddlywiki_archive
resource "wasabi_user" "tiddlywiki_sa" {
  provider = wasabi.us-east-1
  name     = "tiddlywiki_service_account"
}


resource "wasabi_access_key" "tiddlywiki_sa_key" {
  provider = wasabi.us-east-1
  user     = wasabi_user.tiddlywiki_sa.name
}
