#
# Nimbus
# Google Cloud Deployment
#

locals {
  # GCP project
  gcp_project_id = "mrzzy-sandbox"
  gcp_region     = "asia-southeast1" # singapore

  # GCE tags for firewall rules
  allow_ssh_tag       = "allow-ssh"
  allow_https_tag     = "allow-https"
  warp_allow_http_tag = "warp-allow-http"
  warp_allow_dev_tag  = "warp-allow-dev"

  # mrzzy's SSH public key
  ssh_public_key = "mrzzy:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBrfd982D9iQVTe2VecUncbgysh/XsZb4YyOhCSSAAtr mrzzy"
}
provider "google" {
  project = local.gcp_project_id
  region  = local.gcp_region
  zone    = "${local.gcp_region}-c"
}

# GCP enabled APIs
resource "google_project_service" "svc" {
  for_each = toset([
    "artifactregistry.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com"
  ])
  service = each.key
}

# GCP: Shared IAM resources
module "iam" {
  source = "./modules/gcp/iam"

  project = local.gcp_project_id
  allow_gh_actions = [
    "mrzzy/nimbus"
  ]
}

# GCP: Shared VPC network VM instances reside on
module "vpc" {
  source = "./modules/gcp/vpc"

  ingress_allows = merge(
    {
      "ssh" = {
        "tag"  = local.allow_ssh_tag,
        "cidr" = "0.0.0.0/0",
        "port" = "22",
      },
      "https" = {
        "tag"  = local.allow_https_tag,
        "cidr" = "0.0.0.0/0",
        "port" = "443",
      },
      "warp-http" = {
        "tag"  = local.warp_allow_http_tag,
        "cidr" = var.warp_allow_ip,
        "port" = "80",
      },
    },
    # create allow rules for WARP VM development ports
    {
      for port in compact(split(",", var.warp_allow_ports)) :
      "warp-dev-${trim(port, " ")}" => {
        "tag"  = local.warp_allow_dev_tag,
        "cidr" = var.warp_allow_ip,
        "port" = trim(port, " "),
      }
    }
  )
}

# GCP: Deploy WARP Box development VM on GCP
# https://github.com/mrzzy/warp
module "warp_vm" {
  source = "./modules/gcp/warp_vm"

  enabled      = var.has_warp_vm
  image        = var.warp_image
  machine_type = var.warp_machine_type
  tags = concat(
    [
      local.allow_ssh_tag,
      local.allow_https_tag,
      local.warp_allow_dev_tag,
    ],
    # allow http for warp vm's http terminal if enabled
    var.warp_http_terminal ? [local.warp_allow_http_tag] : [],
  )
  disk_size_gb = var.warp_disk_size_gb

  web_tls_cert   = module.tls_cert.full_chain_cert
  web_tls_key    = module.tls_cert.private_key
  ssh_public_key = local.ssh_public_key
}

# GCP: enroll project-wide ssh key for ssh access to VMs
resource "google_compute_project_metadata_item" "ssh_keys" {
  key   = "ssh-keys"
  value = local.ssh_public_key
}

# GCP Artifact Registry to store containers built by CI
resource "google_artifact_registry_repository" "nimbus" {
  location      = local.gcp_region
  repository_id = "nimbus"
  description   = "Stores containers built from github.com/mrzzy/nimbus's CI Pipeline."
  format        = "DOCKER"
}
# allow Github Actions workers to push containers to Artifact Registry
resource "google_artifact_registry_repository_iam_member" "gh-actions" {
  repository = google_artifact_registry_repository.nimbus.name
  location   = google_artifact_registry_repository.nimbus.location
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:gh-actions-mrzzy-nimbus@mrzzy-sandbox.iam.gserviceaccount.com"
}
