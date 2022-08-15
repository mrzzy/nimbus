#
# Nimbus
# Terraform Deployment: Linode Kubernetes Engine
#

terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = ">=1.28.0, <1.29.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.12.1"
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
# tls
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
# S3 CSI credentials
resource "kubernetes_secret" "s3_csi" {
  metadata {
    name      = "csi-s3-secret"
    namespace = "kube-system"
  }

  data = {
    "endpoint"        = var.s3_csi.s3_endpoint,
    "accessKeyID"     = var.s3_csi.access_key_id,
    "secretAccessKey" = var.s3_csi.access_key,
    "region"          = ""
  }
}
