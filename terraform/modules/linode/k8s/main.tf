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
