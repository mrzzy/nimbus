#
# Nimbus
# Terraform Deployment
#

locals {
  domain      = "mrzzy.co"
  domain_slug = replace(local.domain, ".", "-")
}

terraform {
  required_version = ">=1.2.0, <1.3.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=4.22.0, <4.23.0"
    }
    linode = {
      source  = "linode/linode"
      version = ">=1.28.0, <1.29.0"
    }
    acme = {
      source  = "vancluever/acme"
      version = ">=2.9.0, <2.10.0"
    }
    b2 = {
      source  = "Backblaze/b2"
      version = "0.8.1"
    }
  }

  # terraform cloud workspace to store terraform state
  # https://learn.hashicorp.com/tutorials/terraform/cloud-migrate?in=terraform/state
  cloud {
    organization = "mrzzy-co"
    workspaces {
      name = "nimbus"
    }
  }
}
# Lets Encrypt ACME TLS certificate issuer
provider "acme" {
  server_url = var.acme_server_url
}
# Issue trusted wildcard TLS certificate for domain via ACME
module "tls_cert" {
  source = "./modules/linode/tls_acme"

  common_name = local.domain
  domains     = ["*.${local.domain}"]
}

# Backblaze B2 Cloud Storage provider
provider "b2" {}

# off-site backup location for volt (laptop)
resource "b2_bucket" "volt_bkp" {
  bucket_name = "${local.domain_slug}-volt-backup"
  bucket_type = "allPrivate"

  default_server_side_encryption {
    algorithm = "AES256"
    mode      = "SSE-B2"
  }
}

# store media files for media streaming service
resource "b2_bucket" "media" {
  bucket_name = "${local.domain_slug}-media"
  bucket_type = "allPrivate"
}
