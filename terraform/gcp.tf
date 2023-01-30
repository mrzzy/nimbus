#
# Nimbus
# Google Cloud Deployment
#

locals {
  gh_repo = "mrzzy/nimbus"

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
    "iam.googleapis.com",
    "appengine.googleapis.com"
  ])
  service = each.key
}

# GCP: Shared IAM resources
module "iam" {
  source = "./modules/gcp/iam"

  project          = local.gcp_project_id
  allow_gh_actions = [local.gh_repo]
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

# GCP: Container Registry to store containers built by CI
data "google_service_account" "nimbus" {
  account_id = module.iam.gh_actions_service_account_ids[local.gh_repo]
}
module "registry" {
  source = "./modules/gcp/registry"

  region = local.gcp_region
  name   = "nimbus"
  allow_writers = [
    "serviceAccount:${data.google_service_account.nimbus.email}"
  ]
}

# GCP: Deploy WARP Box development VM on GCP
# https://github.com/mrzzy/warp
module "warp_vm" {
  source = "github.com/mrzzy/warp//deploy/terraform/gcp_vm?ref=8310bb8962a1dbeb3928b2172a3ddb52f32555da"

  enabled      = var.has_warp_vm
  image        = var.warp_image
  machine_type = var.warp_machine_type
  disk_type    = "pd-ssd"

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

# Google App Engine (GAE) Proxy
resource "google_app_engine_application" "app" {
  project        = local.gcp_project_id
  location_id    = local.gcp_region
  serving_status = var.has_gae_proxy ? "SERVING" : "USER_DISABLED"
}

module "proxy_service" {
  source     = "./modules/gcp/proxy_gae"
  container  = "${module.registry.repo_prefix}/proxy-gae@sha256:6cdfba6b7366c9c0f1897565cef1ddaad4ef4ee2a7af99824c254bba00b0c4ed"
  proxy_spec = var.has_gae_proxy ? var.gae_proxy_spec : ""
}
