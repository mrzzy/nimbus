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
    "artifactregistry.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "appengine.googleapis.com"
  ])
  service = each.key
}

# Shared IAM resources
module "iam" {
  source = "./modules/gcp/iam"

  project              = local.gcp_project_id
  allow_gh_actions     = [local.gh_repo]
  pipeline_logs_bucket = google_storage_bucket.pipeline_logs.name
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

# Deploy WARP Box development VM on GCP
# https://github.com/mrzzy/warp
module "warp_vm" {
  source = "github.com/mrzzy/warp//deploy/terraform/gcp_vm?ref=1588a96f590f5bd515fe9e3e4676317b02196ae3"

  gcp_project  = local.gcp_project_id
  region_zone  = "asia-southeast1-c" # Singapore
  enabled      = var.has_warp_vm
  image        = var.warp_image
  machine_type = var.warp_machine_type
  disk_type    = "pd-standard"

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

# Google Kubernetes Engine Cluster
locals {
  tls_secret = {
    name = "${local.domain_slug}-tls",
    type = "kubernetes.io/tls",
    data = {
      "tls.crt" = module.tls_cert.full_chain_cert,
      "tls.key" = module.tls_cert.private_key,
    },
  }
}

module "gke" {
  source = "./modules/gcp/gke"

  region_zone = "${local.gcp_region}-c"
  k8s_version = "1.26"

  # K8s workers
  machine_type          = "n1-standard-2" # 2vCPU, 7.5GB RAM
  storage_class         = "pd-standard"
  n_min_workers         = 1
  n_max_workers         = 5
  use_spot_workers      = true
  service_account_email = module.iam.gke_service_account_email

  # K8s Namespaces to deploy
  namespaces = [
    "auth",
    "analytics",
    "csi-rclone",
    "monitoring",
    "media",
    "library",
    "pipeline",
    "proxy",
  ]

  # K8s Secrets to deploy
  # NOTE: remember to add a key here for every entry added to secrets below
  secret_keys = [
    "default-${local.domain_slug}-tls",
    "auth-${local.domain_slug}-tls",
    "monitoring-${local.domain_slug}-tls",
    "media-${local.domain_slug}-tls",
    "library-${local.domain_slug}-tls",
    "pipeline-${local.domain_slug}-tls",
    "analytics-${local.domain_slug}-tls",
    "proxy-${local.domain_slug}-tls",
    "rclone",
    "loki-s3",
  ]
  secrets = {
    # TLS credentials to add to the cluster as K8s secrets.
    "default-${local.domain_slug}-tls"    = local.tls_secret,
    "auth-${local.domain_slug}-tls"       = merge(local.tls_secret, { namespace = "auth" }),
    "monitoring-${local.domain_slug}-tls" = merge(local.tls_secret, { namespace = "monitoring" }),
    "media-${local.domain_slug}-tls"      = merge(local.tls_secret, { namespace = "media" }),
    "library-${local.domain_slug}-tls"    = merge(local.tls_secret, { namespace = "library" }),
    "pipeline-${local.domain_slug}-tls"   = merge(local.tls_secret, { namespace = "pipeline" }),
    "analytics-${local.domain_slug}-tls"  = merge(local.tls_secret, { namespace = "analytics" }),
    "proxy-${local.domain_slug}-tls"      = merge(local.tls_secret, { namespace = "proxy" }),
    # CSI-Rclone credentials: csi-rclone implements persistent volumes on Backblaze B2
    "rclone" = {
      name      = "rclone-secret"
      namespace = "csi-rclone"
      data = {
        "remote"               = "s3",
        "s3-provider"          = "Other", # any other S3 compatible provider
        "s3-endpoint"          = local.b2_endpoint,
        "s3-access-key-id"     = b2_application_key.k8s_csi.application_key_id, #gitleaks:allow
        "s3-secret-access-key" = b2_application_key.k8s_csi.application_key,    #gitleaks:allow
      }
    },
    "loki-s3" = {
      name      = "loki-s3-credentials"
      namespace = "monitoring"
      data = {
        "S3_ENDPOINT"          = local.b2_endpoint,
        "S3_ACCESS_KEY_ID"     = b2_application_key.k8s_loki.application_key_id, #gitleaks:allow
        "S3_SECRET_ACCESS_KEY" = b2_application_key.k8s_loki.application_key,    #gitleaks:allow
        "LOKI_LOG_BUCKET"      = b2_bucket.logs.bucket_name,
      }
    },
  }

  # Export external ips of k8s service
  export_service_ips = [
    "ingress-nginx::ingress-nginx-controller",
    "proxy::shadowsocks",
    "proxy::naiveproxy",
  ]
}

# GCS
# storage bucket to store Airflow pipeline remote logs
resource "google_storage_bucket" "pipeline_logs" {
  name     = "${local.gcs_bucket_prefix}-pipeline-logs"
  location = upper(local.gcp_region)
}
