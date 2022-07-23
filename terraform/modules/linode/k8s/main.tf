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

# TLS K8s secrets
resource "kubernetes_secret" "tls" {
  for_each = var.tls_certs

  type = "kubernetes.io/tls"

  metadata {
    name = each.key
    # default to the 'default' k8s namespace if unspecified
    namespace = lookup(each.value, "namespace", "default")
  }

  data = {
    # convert PEM to DER by dropping BEGIN CERTIFICATE & END CERTIFICATE header / footer.
    # k8s tls secrets stores TLS credentials in base64 encoded DER format
    # https://kubernetes.io/docs/concepts/configuration/secret/#tls-secrets
    "tls.crt" = base64encode(
      join("\n",
        slice(
          split("\n", each.value["cert"]),
          1, length(split("\n", each.value["cert"]))
        )
      )
    )
    "tls.key" = base64encode(
      join("\n",
        slice(
          split("\n", var.tls_keys[each.key]),
          1, length(split("\n", var.tls_keys[each.key]))
        )
      )
    )
  }
}
