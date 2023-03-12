#
# Nimbus
# Terraform Deployment: Google Kubernetes Engine
# Input Variables
#

variable "region" {
  type        = string
  description = "GCP region to deploy the K8s cluster to "
}

variable "k8s_version" {
  type        = string
  description = "Version of the Kubernetes to deploy."
}

variable "machine_type" {
  type        = string
  description = "GCE VM instance type to use when creating workers for K8s."
}

variable "n_workers" {
  type        = number
  description = "No. of worker nodes to create for K8s."
}

variable "service_account_email" {
  type        = string
  description = "Email of the GCP service account used to authenticate K8s workloads on GCP."
}

variable "secret_keys" {
  type        = set(string)
  description = <<-EOF
    Keys used to identify secrets specified in 'secrets' var.
    Each key should correspond to an entry in the 'secrets' var.
    These keys are used to iterate over 'secrets' as secret values cannot be iterated over with terraform's for_each.
  EOF
  default     = []
}

variable "secrets" {
  type = map(object({
    namespace = optional(string, "default"),
    name      = string,
    type      = optional(string, "Opaque"),
    data      = map(string)
  }))
  sensitive   = true
  description = "Map of K8s Secrets to create in the cluster within the given namespace."
  default     = {}
}
