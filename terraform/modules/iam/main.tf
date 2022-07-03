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

# service account for WARP VM - needed to restrict IAM permissions on WARP VM
# as the default service account gives GCP project wide editor permissions.
resource "google_service_account" "warp" {
  project      = var.project
  account_id   = "warp-vm"
  display_name = "Service account for WARP VM instance(s)."
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

# IAM Role Bindings
# project editor role
resource "google_project_iam_binding" "editor" {
  project = var.project
  role    = "roles/editor"
  members = [
    google_service_account.terraform.email
  ]
}

# compute instance admin
resource "google_project_iam_binding" "vm_admin" {
  project = var.project
  role    = "roles/compute.instanceAdmin.v1"
  members = [
    google_service_account.warp_builder.email
  ]
}

resource "google_project_iam_binding" "service_account_user" {
  project = var.project
  role    = "roles/iam.serviceAccountUser"
  members = [
    google_service_account.warp_builder.email
  ]
}
