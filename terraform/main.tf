#
# Nimbus
# Terraform Deployment
#

locals {
  allow_ssh_tag   = "allow-ssh"
  allow_http_tag  = "allow-http"
  allow_https_tag = "allow-https"
}

terraform {
  required_version = ">=1.1.0, <1.3.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=4.22.0, <4.23.0"
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
  project = "mrzzy-sandbox"
  region  = "asia-southeast1"
  zone    = "asia-southeast1-c"
}

# Shared resources for GCE VMs
module "gce" {
  source = "./modules/gce"

  ingress_allows = {
    (local.allow_ssh_tag)   = 22
    (local.allow_http_tag)  = 80
    (local.allow_https_tag) = 443
  }
}

# Deploy WARP Box development VM on GCP
# https://github.com/mrzzy/warp
module "warp_vm" {
  source = "./modules/warp_vm"

  enabled       = var.has_warp_vm
  image         = var.warp_image
  machine_type  = var.warp_machine_type
  allow_ssh_tag = local.allow_ssh_tag
  disk_size_gb  = var.warp_disk_size_gb
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
  routes = var.has_warp_vm ? { "vm.warp" : local.warp_ip } : {}
}
