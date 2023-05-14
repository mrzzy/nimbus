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
  member  = google_service_account.warp_builder.member
}

# Workload Identity Pool & Service Account to authenticate Github Action's runners
resource "google_service_account" "actions" {
  for_each     = toset(var.allow_gh_actions)
  project      = var.project
  display_name = "github.com/${each.key} Github Action Runner"
  account_id   = format("gh-actions-%s", replace(each.key, "/", "-"))
  description  = "Service account to authenticate github.com/${each.key}'s Github Actions Runners"
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
resource "google_project_iam_member" "actions_k8s_role" {
  for_each = toset(var.allow_gh_actions)
  project  = var.project
  role     = "roles/container.admin"
  member   = google_service_account.actions[each.key].member
}

# service account to authenticate workloads on GKE
resource "google_service_account" "gke" {
  project     = var.project
  account_id  = "gke-workload"
  description = "Service Account to authenticate K8s workloads on GKE."
}
