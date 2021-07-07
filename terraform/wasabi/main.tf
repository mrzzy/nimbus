#
# nimbus
# terraform deploy for wasabi storage
#

terraform {
  required_providers {
    wasabi = {
      source  = "k-t-corp/wasabi"
      version = "4.1.1"
    }
  }
}

provider "wasabi" {
  alias  = "wasabi-eu"
  region = "eu-central-1"

  access_key = var.access_key
  secret_key = var.secret_key
}

provider "wasabi" {
  alias  = "wasabi-us"
  region = "us-west-2"

  access_key = var.access_key
  secret_key = var.secret_key
}
