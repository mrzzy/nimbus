#
# Nimbus
# Terraform Deployment
#

locals {
  domain      = "mrzzy.co"
  domain_slug = replace(local.domain, ".", "-")
}

terraform {
  required_version = ">=1.3.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.84.0"
    }
    acme = {
      source  = "vancluever/acme"
      version = "2.20.0"
    }
    b2 = {
      source  = "Backblaze/b2"
      version = "0.8.9"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.24.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"
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
  source = "./modules/tls_acme"

  dns_provider = "cloudflare"
  common_name  = local.domain
  domains      = ["*.${local.domain}"]
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

# off-site backup location for pickle (laptop)
resource "b2_bucket" "backup_pickle" {
  bucket_name = "${local.domain_slug}-backup-pickle"
  bucket_type = "allPrivate"

  default_server_side_encryption {
    algorithm = "AES256"
    mode      = "SSE-B2"
  }
}

# bucket for storing media files for Media Streaming Service (Jellyfin + rTorrent-flood)
resource "b2_bucket" "media" {
  bucket_name = "${local.domain_slug}-media"
  bucket_type = "allPrivate"
}
# bucket for storing logs (Loki)
resource "b2_bucket" "logs" {
  bucket_name = "${local.domain_slug}-logs"
  bucket_type = "allPrivate"
}
