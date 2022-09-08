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
  source = "./modules/linode/k8s"
  region = local.linode_region

  machine_type = "g6-standard-2" # 2vCPU, 2GB
  n_workers    = 1

  # TLS credentials to add to the cluster as K8s secrets.
  tls_certs = {
    "${local.domain_slug}-tls" = {
      "cert" = module.tls_cert.full_chain_cert,
    }
  }
  tls_keys = {
    "${local.domain_slug}-tls" = module.tls_cert.private_key,
  }

  # Configure S3 CSI to provision volumes backed by B2 buckets
  s3_csi = {
    access_key    = b2_application_key.k8s_csi.application_key    #gitleaks:allow
    access_key_id = b2_application_key.k8s_csi.application_key_id #gitleaks:allow
    s3_endpoint   = local.b2_endpoint
  }
}
