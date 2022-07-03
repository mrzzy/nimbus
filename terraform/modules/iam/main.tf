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
# service account for terraform itself.
resource "google_service_account" "terraform" {
  project     = var.project
  account_id  = "nimbus-ci-terraform"
  description = "Service account used by Terraform itself to provision resources."

  lifecycle {
    prevent_destroy = true
  }
}

# service account for WARP VM - needed to restrict IAM permissions on WARP VM
# as the default service account gives GCP project wide editor permissions.
resource "google_service_account" "warp" {
  project      = var.project
  account_id   = "warp-vm"
  display_name = "Service account for WARP VM instance(s)."
}

# IAM Role Bindings
# project editor role
resource "google_project_iam_binding" "editor" {
  project = var.project
  role    = "roles/editor"
  members = [
    google_service_account.terraform.email
  ]
}
