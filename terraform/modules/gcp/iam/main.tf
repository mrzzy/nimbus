#
# Nimbus
# Terraform Deployment: Identity & Access
#

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=4.22.0"
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

# Workload Identity Pool & Service Account to authenticate Github Action's runners
resource "google_service_account" "actions" {
  for_each    = toset(var.allow_gh_actions)
  project     = var.project
  account_id  = format("gh-actions-%s", replace(each.key, "/", "-"))
  description = "Service account to authenticate github.com/${each.key}'s Github Actions Runners"
}
module "gh_oidc" {
  for_each   = toset(var.allow_gh_actions)
  source     = "github.com/terraform-google-modules/terraform-google-github-actions-runners//modules/gh-oidc"
  project_id = var.project
  # workload identity pool & provider
  pool_id     = format("gh-actions-%s", replace(each.key, "/", "-"))
  provider_id = format("gh-oidc-provider-%s", replace(each.key, "/", "-"))
  # service accounts authenticated identities are authorised to impersonate
  sa_mapping = {
    "gh-actions" = {
      sa_name   = google_service_account.actions[each.key].id
      attribute = "attribute.repository/${each.key}"
    }
  }
}

# service account to authenticate workloads on GKE
resource "google_service_account" "gke" {
  project     = var.project
  account_id  = "gke-workload"
  description = "Service Account to authenticate K8s workloads on GKE."
}
