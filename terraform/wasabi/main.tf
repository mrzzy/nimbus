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
  alias  = "us-west-1"
  region = "us-west-1"

  endpoints {
    sts = "https://sts.wasabisys.com"
    iam = "https://iam.wasabisys.com"
    s3  = "https://s3.us-west-1.wasabisys.com"
  }

  access_key = var.access_key
  secret_key = var.secret_key
}
