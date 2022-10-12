#
# Nimbus
# Terraform Deployment: Linode Kubernetes Engine
#

terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "<1.29.4"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "<2.14.1"
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
# Opaque
resource "kubernetes_secret" "opaque" {
  for_each = toset(var.secret_keys)

  type = var.secrets[each.value].type
  metadata {
    name      = var.secrets[each.value].name
    namespace = var.secrets[each.value].namespace
  }
  data = var.secrets[each.value].data
}
