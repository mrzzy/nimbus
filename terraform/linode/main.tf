#
# nimbus
# terraform deploy for linode cloud
#

terraform {
  backend "remote" {
    organization = "mrzzy-co"

    workspaces {
      name = "nimbus-terraform-linode"
    }
  }
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "1.19.1"
    }
  }
  required_version = "1.0.1"
}

## Providers ##
provider "linode" {
  token = var.linode_token
}
