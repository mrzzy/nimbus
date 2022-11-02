#
# Nimbus
# Terraform Deployment
#

locals {
  domain      = "mrzzy.co"
  domain_slug = replace(local.domain, ".", "-")
}

terraform {
  required_version = "<1.3.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "<4.42.2"
    }
    linode = {
      source  = "linode/linode"
      version = "<1.29.5"
    }
    acme = {
      source  = "vancluever/acme"
      version = "<2.11.2"
    }
    b2 = {
      source  = "Backblaze/b2"
      version = "0.8.1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "3.27.0"
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
# App Key to auth S3 CSI for provisioning B2 Bucket backed K8s Persistent Volumes
locals {
  b2_capabilities = [
    "readBuckets",
    "listFiles",
    "readFiles",
    "shareFiles",
    "writeFiles",
    "deleteFiles",
  ]
}
resource "b2_application_key" "k8s_csi" {
  key_name     = "k8s-csi"
  capabilities = concat(local.b2_capabilities, ["writeBuckets"])
}
# App Key to auth Loki for persisting logs
resource "b2_application_key" "k8s_loki" {
  key_name     = "k8s-loki"
  bucket_id    = b2_bucket.logs.id
  capabilities = local.b2_capabilities
}
