#
# Nimbus
# Terraform Deployment: WARP VM on GCP
#

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=4.22.0, <4.23.0"
    }
  }
}

locals {
  warp_disk_id = "warp-disk"
}

data "google_compute_image" "warp_box" {
  name = var.image
}

data "google_compute_network" "sandbox" {
  name = "sandbox"
}

# disk for persistent storage when using the ephemeral development VM
resource "google_compute_disk" "warp_disk" {
  name = "warp-box-disk"
  size = var.disk_size_gb
}

# development VM instance
resource "google_compute_instance" "wrap_vm" {
  count        = var.enabled ? 1 : 0
  name         = "warp-box-vm"
  machine_type = var.machine_type
  tags         = var.tags

  boot_disk {
    initialize_params {
      image = data.google_compute_image.warp_box.self_link
    }
  }

  attached_disk {
    source = google_compute_disk.warp_disk.self_link
    # accessible via /dev/disk/by-id/google- prefix
    device_name = local.warp_disk_id
  }

  network_interface {
    network = data.google_compute_network.sandbox.self_link
    access_config {
      network_tier = "STANDARD"
    }
  }

  metadata = {
    user-data = templatefile("${path.module}/templates/cloud_init.yaml", {
      warp_disk_device = "/dev/disk/by-id/google-${local.warp_disk_id}"
      ttyd_cert        = var.web_tls_cert
      ttyd_key         = var.web_tls_key
    })
  }
}
