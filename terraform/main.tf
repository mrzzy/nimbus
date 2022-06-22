#
# Nimbus
# Terraform Deployment
#

locals {
  gcp_project_id    = "mrzzy-sandbox"
  allow_ssh_tag     = "allow-ssh"
  allow_http_tag    = "allow-http"
  allow_https_tag   = "allow-https"
  domain            = "mrzzy.co"
  warp_vm_subdomain = "vm.warp"
}

terraform {
  required_version = ">=1.1.0, <1.3.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=4.22.0, <4.23.0"
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

# Lets Encrypt ACME TLS certificate issuer
provider "acme" {
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

# use terraform service account to auth DNS requests used to perform dns-01 challenge
data "google_service_account" "terraform" {
  account_id = "nimbus-ci-terraform"
}

# Issue TLS cert via ACME
module "tls_cert" {
  source = "./modules/tls_acme"

  common_name = local.domain
  domains = [
    for subdomain in [
      (local.warp_vm_subdomain)
    ] : "${subdomain}.${local.domain}"
  ]

  gcp_project_id          = local.gcp_project_id
  gcp_service_account_key = var.gcp_service_account_key
}

# Shared resources for GCE VMs
module "gce" {
  source = "./modules/gce"

  ingress_allows = {
    (local.allow_ssh_tag)   = 22
    (local.allow_https_tag) = 443
  }
}

# Deploy WARP Box development VM on GCP
# https://github.com/mrzzy/warp
module "warp_vm" {
  source = "./modules/warp_vm"

  enabled      = var.has_warp_vm
  image        = var.warp_image
  machine_type = var.warp_machine_type
  tags = [
    local.allow_ssh_tag,
    local.allow_http_tag,
    local.allow_https_tag,
  ]
  disk_size_gb = var.warp_disk_size_gb

  web_tls_cert = module.tls_cert.full_chain_cert
  web_tls_key  = module.tls_cert.private_key
}
locals {
  warp_ip = (
    module.warp_vm.external_ip == null ?
    null : nonsensitive(module.warp_vm.external_ip)
  )
}

# DNS zone & routes for mrzzy.co domain
module "dns" {
  source = "./modules/cloud_dns"

  domain = "mrzzy.co"
  # only create dns route for WARP VM if its deployed
  routes = var.has_warp_vm ? { (local.warp_vm_subdomain) : local.warp_ip } : {}
}
