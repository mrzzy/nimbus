#
# Nimbus
# Terraform Deployment: Linode Kubernetes Engine
#

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=4.22.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "< 2.18.2"
    }
  }
}

# GKE Cluster
resource "google_container_cluster" "main" {
  name     = "main"
  location = var.region

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}

# Primary GKE Worker node pool
resource "google_container_node_pool" "primary" {
  cluster    = google_container_cluster.main.name
  name       = "primary"
  location   = var.region
  version    = var.k8s_version
  node_count = var.n_workers

  node_config {
    machine_type    = var.machine_type
    disk_type       = "pd-balanced"
    disk_size_gb    = 30
    service_account = var.service_account_email
  }

  upgrade_settings {
    # allow GKE to create 1 extra node in the pool to perform rolling upgrades of k8s version
    max_surge = 1
  }
}

# Configure Terraform provider for Kubernetes access to GKE cluster
locals {
  master_auth = google_container_cluster.main.master_auth.0
}

# use google provider's access token to authenticate k8s provider
data "google_client_config" "provider" {}
provider "kubernetes" {
  host                   = "https://${google_container_cluster.main.endpoint}"
  token                  = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(local.master_auth.cluster_ca_certificate)
}

# K8s Secrets
# Opaque
resource "kubernetes_secret" "opaque" {
  for_each = toset(var.secret_keys)
  type     = var.secrets[each.value].type
  metadata {
    name      = var.secrets[each.value].name
    namespace = var.secrets[each.value].namespace
  }
  data = var.secrets[each.value].data
}
