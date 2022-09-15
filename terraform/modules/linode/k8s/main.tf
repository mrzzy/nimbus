#
# Nimbus
# Terraform Deployment: Linode Kubernetes Engine
#

terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "<1.29.3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "<2.14.0"
    }
  }
}

# Deploy a single node k8s cluster on Linode
resource "linode_lke_cluster" "main" {
  label       = "main"
  k8s_version = "1.23"
  region      = var.region

  pool {
    type  = var.machine_type
    count = 1
  }
}

# Configure Terraform provider for Kubernetes to access K8s on Linode
locals {
  kubeconfig = yamldecode(base64decode(linode_lke_cluster.main.kubeconfig))
}
provider "kubernetes" {
  host = linode_lke_cluster.main.api_endpoints[0]

  token = one(local.kubeconfig["users"])["user"]["token"]
  cluster_ca_certificate = base64decode(
    one(local.kubeconfig["clusters"])["cluster"]["certificate-authority-data"]
  )
}

# Ingress controller service
data "kubernetes_service" "ingress" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
}

# K8s Secrets
# TLS
resource "kubernetes_secret" "tls" {
  for_each = var.tls_certs

  type = "kubernetes.io/tls"

  metadata {
    name = each.key
    # default to the 'default' k8s namespace if unspecified
    namespace = lookup(each.value, "namespace", "default")
  }

  data = {
    "tls.crt" = each.value["cert"],
    "tls.key" = var.tls_keys[each.key],
  }
}
# CSI-Rclone credentials: csi-rclone implements persistent volumes on S3
resource "kubernetes_secret" "csi-rclone" {
  metadata {
    name      = "rclone-secret"
    namespace = "csi-rclone"
  }

  data = {
    "remote"               = "s3",
    "s3-provider"          = "Other", # any other S3 compatible provider
    "s3-endpoint"          = var.s3_csi.s3_endpoint,
    "s3-access-key-id"     = var.s3_csi.access_key_id,
    "s3-secret-access-key" = var.s3_csi.access_key,
  }
}
