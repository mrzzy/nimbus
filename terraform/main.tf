#
# Nimbus
# Terraform Deployment
#

locals {
  gcp_project_id    = "mrzzy-sandbox"
  domain            = "mrzzy.co"
  warp_vm_subdomain = "vm.warp"

  # GCE tags for firewall rules
  allow_ssh_tag       = "allow-ssh"
  allow_https_tag     = "allow-https"
  warp_allow_http_tag = "warp-allow-http"

  # mrzzy's SSH public key
  ssh_public_key = "mrzzy:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBrfd982D9iQVTe2VecUncbgysh/XsZb4YyOhCSSAAtr mrzzy"
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

# Google Cloud Platform
provider "google" {
  project = local.gcp_project_id
  region  = "asia-southeast1"
  zone    = "asia-southeast1-c"
}

# Linode Cloud
provider "linode" {}

# Lets Encrypt ACME TLS certificate issuer
provider "acme" {
  server_url = var.acme_server_url
}

# Shared IAM resources
module "iam" {
  source = "./modules/gcp/iam"

  project = local.gcp_project_id
}

# Issue TLS cert via ACME
module "tls_cert" {
  source = "./modules/linode/tls_acme"

  common_name = local.domain
  domains = [
    for subdomain in [
      (local.warp_vm_subdomain)
    ] : "${subdomain}.${local.domain}"
  ]
}

# Shared VPC network VM instances reside on
module "vpc" {
  source = "./modules/gcp/vpc"

  ingress_allows = {
    (local.allow_ssh_tag)       = ["0.0.0.0/0", "22"]
    (local.allow_https_tag)     = ["0.0.0.0/0", "443"]
    (local.warp_allow_http_tag) = [var.warp_allow_ip, "80"]
  }
}

# Deploy WARP Box development VM on GCP
# https://github.com/mrzzy/warp
module "warp_vm" {
  source = "./modules/gcp/warp_vm"

  enabled      = var.has_warp_vm
  image        = var.warp_image
  machine_type = var.warp_machine_type
  tags = concat(
    [
      local.allow_ssh_tag,
      local.allow_https_tag,
    ],
    # allow http for warp vm's http terminal if enabled
    var.warp_http_terminal ? [local.warp_allow_http_tag] : []
  )
  disk_size_gb = var.warp_disk_size_gb

  web_tls_cert   = module.tls_cert.full_chain_cert
  web_tls_key    = module.tls_cert.private_key
  ssh_public_key = local.ssh_public_key
}
locals {
  warp_ip = (
    module.warp_vm.external_ip == null ? null : module.warp_vm.external_ip
  )
}

# DNS zone & routes for mrzzy.co domain
module "dns" {
  source = "./modules/linode/dns"

  domain = "mrzzy.co"
  # only create dns route for WARP VM if its deployed
  routes = var.has_warp_vm ? { (local.warp_vm_subdomain) : local.warp_ip } : {}
}
