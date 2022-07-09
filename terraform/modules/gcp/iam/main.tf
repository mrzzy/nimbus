#
# Nimbus
# Terraform Deployment: Identity & Access
#

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=4.22.0, <4.23.0"
    }
  }
}

# Service Accounts
# service account for terraform itself to apply cloud infrastructure on GCP
resource "google_service_account" "terraform" {
  project     = var.project
  account_id  = "nimbus-ci-terraform"
  description = "Service account used by Terraform itself to provision resources."

  lifecycle {
    prevent_destroy = true
  }
}

# service account for WARP VM image Packer builder
resource "google_service_account" "warp_builder" {
  project     = var.project
  account_id  = "warp-packer-builder"
  description = <<-EOF
  Service Account for WARP VM's Packer builder to build WARP VM images on
  GCE VM instances.
  EOF
}
