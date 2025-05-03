#
# Nimbus
# Google Cloud Deployment
#

locals {
  # GCP project
  gcp_project_id = "mrzzy-sandbox"
  gcp_region     = "asia-southeast1" # singapore

  # GCE tags for firewall rules
  allow_ssh_tag   = "allow-ssh"
  allow_https_tag = "allow-https"

  # GCS buckets
  gcs_bucket_prefix = local.domain_slug

  # mrzzy's SSH public key
  ssh_public_key = "mrzzy:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBrfd982D9iQVTe2VecUncbgysh/XsZb4YyOhCSSAAtr mrzzy"

  # Backblaze B2 S3-compatible regional endpoint
  b2_endpoint = "https://s3.us-west-004.backblazeb2.com"
}
provider "google" {
  project = local.gcp_project_id
  region  = local.gcp_region
  zone    = "${local.gcp_region}-c"
}

# GCP enabled APIs
resource "google_project_service" "svc" {
  for_each = toset([
    "container.googleapis.com",
    "iam.googleapis.com",
    "appengine.googleapis.com"
  ])
  service = each.key
}

# Shared IAM resources
module "iam" {
  source = "./modules/gcp/iam"

  project = local.gcp_project_id
}

# enroll project-wide ssh key for ssh access to VMs
resource "google_compute_project_metadata_item" "ssh_keys" {
  key   = "ssh-keys"
  value = local.ssh_public_key
}

# Shared VPC network VM instances reside on
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
    },
  )
}
