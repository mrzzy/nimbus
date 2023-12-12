#
# Nimbus
# Terraform Deployment: Identity & Access
#

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.22.0"
    }
  }
}

# Service Accounts
# service account for terraform itself to apply cloud infrastructure on GCP
resource "google_service_account" "terraform" {
  project      = var.project
  account_id   = "nimbus-ci-terraform"
  display_name = "Nimbus CI Terraform"
  description  = "Service account used by Terraform itself to provision resources."

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_project_iam_member" "terraform_roles" {
  for_each = toset([
    "roles/editor",
    "roles/iam.workloadIdentityPoolAdmin",
    "roles/iam.securityAdmin",
    "roles/iam.serviceAccountAdmin",
  ])
  project = var.project
  role    = each.key
  member  = google_service_account.terraform.member

  lifecycle {
    prevent_destroy = true
  }
}

# service account for Nimbus CI pipeline to cleanup orphaned GCP disks
resource "google_service_account" "nimbus_ci" {
  project      = var.project
  account_id   = "nimbus-ci"
  display_name = "Nimbus CI pipeline"
  description  = <<-EOF
  Service account used by Nimbus CI pipeline to clean up orphaned GCE persistent disk(s).
  EOF
}

# account for WARP CI pipeline's packer to build on GCE
resource "google_service_account" "warp_builder" {
  project      = var.project
  account_id   = "warp-packer-builder"
  display_name = "WARP Packer GCE Builder"
  description  = <<-EOF
  Service Account for WARP VM's Packer builder to build WARP VM images on
  GCE VM instances.
  EOF
}

resource "google_project_iam_member" "warp_builder_roles" {
  for_each = toset([
    "roles/compute.instanceAdmin.v1",
    "roles/iam.serviceAccountUser",
  ])
  project = var.project
  role    = each.key
  member  = google_service_account.warp_builder.member
}

# service account for WARP CI pipeline to cleanup GCE image on branch delete
resource "google_service_account" "warp_ci" {
  project     = var.project
  account_id  = "warp-ci"
  description = <<-EOF
  Service account for mrzzy/warp's Github Action's CI pipeline to clean WARP box
  images built for deleted branches.
  EOF
}

resource "google_project_iam_member" "warp_ci_gce_role" {
  project = var.project
  role    = "roles/compute.instanceAdmin.v1"
  member  = google_service_account.warp_ci.member
}
