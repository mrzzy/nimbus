#
# Nimbus
# Google Kubernetes Engine Terraform Module
# Input Variables
#

variable "region_zone" {
  type        = string
  description = "GCP region & zone to deploy the K8s cluster to "
}

variable "k8s_version" {
  type        = string
  description = "Version of the Kubernetes to deploy in the format: <MAJOR>.<MINOR>"
}

variable "machine_type" {
  type        = string
  description = "GCE VM instance type to use when creating workers for K8s."
}

variable "storage_class" {
  type        = string
  description = "GCE storage class to select for persistent disks provisioned for K8s workers."
}

variable "n_min_workers" {
  type        = number
  description = "Minimum No. of worker nodes to create for K8s."
}

variable "n_max_workers" {
  type        = number
  description = "Max No. of worker nodes to create for to support load surges."
}

variable "use_spot_workers" {
  type        = bool
  description = "Whether to use GCE spot VMs for worker nodes"
  default     = false
}

variable "service_account_email" {
  type        = string
  description = "Email of the GCP service account used to authenticate K8s workloads on GCP."
}

variable "namespaces" {
  type        = set(string)
  description = "List of Kubernetes namespaces to create on the GKE cluster."
  default     = []
}

variable "secret_keys" {
  type        = set(string)
  description = <<-EOF
    Keys used to identify secrets specified in 'secrets' var.
    Each key should correspond to an entry in the 'secrets' var.
    These keys are used to iterate over 'secrets' as secret values cannot be iterated o
    over with terraform's for_each.
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

variable "export_service_ips" {
  type        = set(string)
  description = <<-EOF
    List of K8s services <namespace>::<name> pairs to export externally accessible ips for.
  EOF
  default     = []
}
