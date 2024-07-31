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
      version = "4.85.0"
    }
    acme = {
      source  = "vancluever/acme"
      version = "2.25.0"
    }
    b2 = {
      source  = "Backblaze/b2"
      version = "0.8.12"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.38.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.113.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.53.1"
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
