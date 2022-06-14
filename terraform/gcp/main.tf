#
# Nimbus
# Terraform Deployment: Google Cloud Platform
#

locals {
  allow_ssh_tag = "allow-ssh"
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

provider "google" {
  project = "mrzzy-sandbox"
  region  = "asia-southeast1"
  zone    = "asia-southeast1-c"
}

# custom VPC with hardened firewall rules (as compared to default VPC)
resource "google_compute_network" "sandbox" {
  name                    = "sandbox"
  description             = "Hardend VPC Network to attach GCE resources to."
  auto_create_subnetworks = "true"
}

# allow SSH traffic to instances tagged with "allow-ssh" tag.
resource "google_compute_firewall" "sandbox" {
  name        = "allow-ssh"
  network     = google_compute_network.sandbox.self_link
  description = "allow SSH traffic to instances tagged with 'allow-ssh' tag."

  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = [local.allow_ssh_tag]
}

# enroll project-wide ssh key for ssh access to VMs
resource "google_compute_project_metadata_item" "ssh_keys" {
  key   = "ssh-keys"
  value = "mrzzy:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBrfd982D9iQVTe2VecUncbgysh/XsZb4YyOhCSSAAtr mrzzy"
}

# Deploy WARP Box development VM
# https://github.com/mrzzy/warp
module "warp_vm" {
  source = "./modules/warp_vm"

  enabled       = var.has_warp_vm
  image         = var.warp_image
  machine_type  = var.warp_machine_type
  allow_ssh_tag = local.allow_ssh_tag
}
