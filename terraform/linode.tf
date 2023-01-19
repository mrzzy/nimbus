#
# Nimbus
# Linode Terraform Deployment
#

locals {
  # Linode deploy region
  linode_region = "ap-south" # singapore
  # Backblaze B2 S3-compatible regional endpoint
  b2_endpoint = "https://s3.us-west-004.backblazeb2.com"
}

# Linode Cloud
provider "linode" {}

# Linode: LKE Cluster
module "k8s" {
  source      = "./modules/linode/k8s"
  k8s_version = "1.24"
  region      = local.linode_region

  machine_type = "g6-dedicated-2" # 2vCPU, 4GB
  n_workers    = 1

  secret_keys = [
    "default-${local.domain_slug}-tls",
    "monitoring-${local.domain_slug}-tls",
    "rclone",
    "loki-s3",
  ]
  secrets = {
    # TLS credentials to add to the cluster as K8s secrets.
    "default-${local.domain_slug}-tls" = {
      name      = "${local.domain_slug}-tls"
      type      = "kubernetes.io/tls"
      namespace = "default",
      data = {
        "tls.crt" = module.tls_cert.full_chain_cert,
        "tls.key" = module.tls_cert.private_key,
      }
    },
    "monitoring-${local.domain_slug}-tls" = {
      name      = "${local.domain_slug}-tls"
      type      = "kubernetes.io/tls"
      namespace = "monitoring",
      data = {
        "tls.crt" = module.tls_cert.full_chain_cert,
        "tls.key" = module.tls_cert.private_key,
      }
    },
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
}
