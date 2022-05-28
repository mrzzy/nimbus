#
# Nimbus
# Terraform Deployment: Google Cloud Platform
#

locals {
  # name of the VPC network to attach provisioned resources to
  vpc_network = "default"
}

terraform {
  required_version = ">=1.1.0, <1.2.0"

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

# enroll project-wide ssh key for ssh access to VMs
resource "google_compute_project_metadata_item" "ssh_keys" {
  key = "ssh-keys"
  value = "mrzzy:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBrfd982D9iQVTe2VecUncbgysh/XsZb4YyOhCSSAAtr mrzzy"
}

# Deploy WARP Box development VM
# https://github.com/mrzzy/warp
data "google_compute_image" "warp_box" {
  name = var.warp_image
}

# disk for persistent storage when using the ephemeral development VM
resource "google_compute_disk" "warp_disk" {
  name = "warp-box-disk"
  size = var.warp_disk_size_gb
}

resource "google_compute_instance" "wrap_vm" {
  name         = "warp-box-vm"
  machine_type = "e2-standard-2"

  boot_disk {
    initialize_params {
      image = data.google_compute_image.warp_box.self_link
    }
  }

  attached_disk {
    source = google_compute_disk.warp_disk.self_link
  }

  network_interface {
    network = local.vpc_network
    access_config {
      network_tier = "STANDARD"
    }
  }
}
